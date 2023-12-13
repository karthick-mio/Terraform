#!/bin/bash

rm -r -f ./.terraform/
az account set -s d46f1336-54a1-40ab-a6d4-2dd115fa4089
az account list -o table | grep True

export VAR_ARM_STORAGE_ACCOUNT_NAME="ngatweutfhrxsuite01st"
export VAR_ARM_STORAGE_CONTAINER_NAME="tfstatebackends"
export VAR_ARM_STORAGE_KEY="tst.eu05.eloisex.terraform.tfstate"
export ARM_ACCESS_KEY="$(az storage account keys list --account-name ${VAR_ARM_STORAGE_ACCOUNT_NAME} --query='[0].value' -o tsv)"

terraform init --backend-config="storage_account_name=${VAR_ARM_STORAGE_ACCOUNT_NAME}" --backend-config="container_name=${VAR_ARM_STORAGE_CONTAINER_NAME}" --backend-config="key=${VAR_ARM_STORAGE_KEY}"
