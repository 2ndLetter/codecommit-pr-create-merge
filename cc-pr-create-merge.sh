#!/bin/bash -ex

echo "Creating Pull Request"

TOKEN=$(date "+%Y%m%d%H%M%S")

aws codecommit create-pull-request \
    --title "Creating Pull Request $TOKEN" \
    --description "scripted PR creation"
    --client-request-token $TOKEN \
    --targets repositoryName=$1,sourceReference=$2

echo "Merging Pull Request"

MY_ARN=$()

aws codecommit list-pull-requests \
    --author-arn $MY_ARN \
    --pull-request-status OPENED \
    --repository-name $1