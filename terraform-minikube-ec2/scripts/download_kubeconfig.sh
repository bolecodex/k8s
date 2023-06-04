#!/usr/bin/env bash

set -o errexit

PRIVATE_KEY_CONTENT=$1
REMOTE_USER=$2
REMOTE_ADDR=$3
OUTPUT_FILE=$4

TMP_PEM_FILE=$(mktemp)
TMP_KUBECONFIG=$(mktemp)

# Writing Key to /tmp
printf "%s\n" "${PRIVATE_KEY_CONTENT[@]}" >$TMP_PEM_FILE
chmod 400 $TMP_PEM_FILE

# Getting the KuebConfig
ssh -i $TMP_PEM_FILE -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_ADDR "sudo cat /root/.kube/config" >$TMP_KUBECONFIG

# if ! command -v yq &>/dev/null; then
#     echo "yq could not be found, you can install it from here https://github.com/mikefarah/yq"
#     exit 1
# fi

# yq eval ".clusters[0].cluster.server = \"https://${REMOTE_ADDR}:8443\"" "$TMP_KUBECONFIG" >$OUTPUT_FILE

# chmod 600 $OUTPUT_FILE

sudo cat $TMP_PEM_FILE > ~/.ssh/minikube.pem
chmod 400 ~/.ssh/minikube.pem
