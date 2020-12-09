#!/bin/bash

function  logInfo() {
    color=`tput setaf 2`
    echo -e $2 "[ ${color}Info$(tput sgr0) ]    $(date "+%D-%T")\t $(tput bold)$1$(tput sgr0)"
}

function  logError() {
    color=`tput setaf 1`
    echo -e $2 "[ ${color}Error$(tput sgr0) ]   $(date "+%D-%T")\t $(tput bold)$1$(tput sgr0)"
}

function  logWarn() {
    color=`tput setaf 3`
    echo -e $2 "[ ${color}Warning$(tput sgr0) ] $(date "+%D-%T")\t $(tput bold)$1$(tput sgr0)"
}

# Check envs
logInfo "Check environment variables..."
to_track=( PLUGIN_RANCHER_URL PLUGIN_RANCHER_TOKEN PLUGIN_KUBERNETES_DEPLOYMENT PLUGIN_KUBERNETES_NAMESPACE PLUGIN_STAMP )
for env in "${to_track[@]}"; do
    if [ "${!env}" = "" ]; then
       	logError "Please set a value for $env"
	exit -1
    fi
done

# Adapter for https://github.com/Quving/rancher-cicd/blob/master/entrypoint.sh
RANCHER_URL=$PLUGIN_RANCHER_URL
RANCHER_TOKEN=$PLUGIN_RANCHER_TOKEN
KUBERNETES_DEPLOYMENT=$PLUGIN_KUBERNETES_DEPLOYMENT
KUBERNETES_NAMESPACE=$PLUGIN_KUBERNETES_NAMESPACE
STAMP=$PLUGIN_STAMP

if [ "${PLUGIN_RANCHER_CONTEXT}" = "" ]; then
    RANCHER_OPTIONS=""
else
    RANCHER_OPTIONS="--context $PLUGIN_RANCHER_CONTEXT"
fi

# Rancher login
logInfo "Login to kubernetes cluster..."
if [ "${PLUGIN_DEBUG}" = "true" ]; then
    rancher login $RANCHER_URL --token $RANCHER_TOKEN $RANCHER_OPTIONS
elif [ "${DEBUG}" = "true" ]; then
    rancher login $RANCHER_URL --token $RANCHER_TOKEN $RANCHER_OPTIONS
else
    rancher login $RANCHER_URL --token $RANCHER_TOKEN $RANCHER_OPTIONS > /dev/null 2>&1
fi

# If login failed.
if [ ! "$(echo $?)" == 0 ]; then
    logError "Wrong credentials provided. Check your 'RANCHER_URL' and 'RANCHER_TOKEN'"
    exit 1
fi
logInfo "Logged in successfully."

# Deploy service
KUBECTL_OPTIONS=${KUBECTL_OPTIONS:-''}
IFS=',' # hyphen (-) is set as delimiter
read -ra ADDR <<< "$KUBERNETES_DEPLOYMENT" # str is read into an array as tokens separated by IFS
for workload in "${ADDR[@]}"; do # access each element of array
    logInfo "Upgrade $workload..."
    rancher kubectl $KUBECTL_OPTIONS set env deployments/$workload -n $KUBERNETES_NAMESPACE GIT_HASH=$STAMP > error.log 2>&1

    # If upgrade failed.
    if [ ! "$(echo $?)" == 0 ]; then
        logError "Error occured while upgrading k8s deployment ($workload). Please check the logs below."
        printf "\n"
        cat error.log
        printf "\n"
        logError "Deployment failed."
        exit 1
    fi
    rancher kubectl $KUBECTL_OPTIONS rollout status deployments/$workload -n $KUBERNETES_NAMESPACE -w
done
logInfo "Upgrade succeeded."

