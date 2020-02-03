#!/bin/bash

set -e

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


# ==  Rancher login ==
# Check envs
logInfo "Check environment variables..."
to_track=( PLUGIN_RANCHER_URL PLUGIN_RANCHER_TOKEN PLUGIN_KUBERNETES_DEPLOYMENT PLUGIN_KUBERNETES_NAMESPACE PLUGIN_STAMP )
for env in "${to_track[@]}"; do
    if [ -z "$env" ]; then
       	logError "Please set a value for $env"
	exit -1
    fi
done

if [ "${PLUGIN_RANCHER_CONTEXT}" = "" ]; then
    RANCHER_OPTIONS=""
else
    RANCHER_OPTIONS="--context $PLUGIN_RANCHER_CONTEXT"
fi

logInfo "Login to kubernetes cluster..."
rancher login $PLUGIN_RANCHER_URL --token $PLUGIN_RANCHER_TOKEN $RANCHER_OPTIONS

# == Deployment ==
logInfo "Upgrade $PLUGIN_KUBERNETES_DEPLOYMENT."
rancher kubectl set env deployments/$PLUGIN_KUBERNETES_DEPLOYMENT -n $PLUGIN_KUBERNETES_NAMESPACE GIT_HASH=$PLUGIN_STAMP
rancher kubectl rollout status deployments/$PLUGIN_KUBERNETES_DEPLOYMENT -n $PLUGIN_KUBERNETES_NAMESPACE -w
logInfo "Upgrade succeeded."
