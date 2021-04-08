#!/bin/bash

# usage
# bash ./deploy.sh

cd _terraform

terraform validate .
terraform apply

rm -rf layer
rm -rf *.zip

cd ../