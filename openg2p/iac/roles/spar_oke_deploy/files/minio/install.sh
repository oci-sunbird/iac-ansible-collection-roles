#!/bin/bash
## Installs activeMQ
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=minio

function create_namespace() {
    if kubectl get namespace $NS &> /dev/null; then
    echo "Namespace $NS exists."
    else
    echo "Namespace $NS does not exist. Creating namespace $NS"
    kubectl create namespace $NS
    fi    
}


function installing_minio() {
  echo Installing minio
  helm -n minio upgrade --install --atomic minio mosip/minio --version 10.1.6

  echo Installing gateways and virtualservice
  EXTERNAL_HOST=$(kubectl get cm global -o jsonpath={.data.mosip-minio-host})

  echo host: $EXTERNAL_HOST
  helm -n $NS upgrade --install --atomic istio-addons /root/mosip-infra/deployment/v3/external/object-store/minio/chart/istio-addons --set externalHost=$EXTERNAL_HOST

  echo Helm installed. Next step is to execute the cred.sh to update secrets in s3 namespace
  return 0
}


# set commands for error handling.
set -e
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errtrace  # trace ERR through 'time command' and other functions
set -o pipefail  # trace ERR through pipes

echo Create $NS namespace
create_namespace
kubectl label namespace $NS istio-injection=enabled --overwrite

installing_minio   # calling function