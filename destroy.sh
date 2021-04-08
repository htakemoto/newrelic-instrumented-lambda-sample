#!/bin/bash

# usage
# bash ./deploy.sh

cd _terraform

terraform validate .
terraform destroy

cd ../