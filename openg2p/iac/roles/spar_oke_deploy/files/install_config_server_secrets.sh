#!/usr/bin/env bash
# Installs config-server secrets
## Usage: ./install_secrets.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=conf-secrets
CHART_VERSION=12.0.2



function create_namespace() {
    if kubectl get namespace $NS &> /dev/null; then
    echo "Namespace $NS exists."
    else
    echo "Namespace $NS does not exist. Creating namespace $NS"
    kubectl create namespace $NS
    fi    
}

function config_secrets() {
  echo Istio label
  kubectl label ns $NS istio-injection=enabled --overwrite
  helm repo update

  echo "Installing Secrets required by config-server"
  helm -n $NS upgrade --install --atomic conf-secrets mosip/conf-secrets --version $CHART_VERSION --wait
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
config_secrets   # calling function
