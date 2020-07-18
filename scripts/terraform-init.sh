#!/usr/bin/env bash
set -euo pipefail

echo "Starting Terraform-init.sh"
echo "argument passed = ${1}"

echo "before pwd = $PWD"
WORKING_DIRECTORY=${1}
echo "WORKING_DIRECTORY = ${WORKING_DIRECTORY}"
cd ${WORKING_DIRECTORY}
echo "new pwd = $PWD"
terraform init -input=false 