#!/bin/bash -e

# Usage:   ./cc-pr-create-merge.sh <commit_message_within_quotes>
# Example: ./cc-pr-create-merge.sh "This is my commit message"

# Push changes to origin 
MSG=$1
git add .
git commit -m "$MSG"
git push

# Creates/merges a PR for the current directory's repository
TOKEN=$(date "+%Y%m%d%H%M%S")
REPO=$(basename $(git remote get-url origin))
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "Creating Pull Request"
aws codecommit create-pull-request \
    --title "Scripted Pull Request Creation $TOKEN" \
    --description "scripted PR creation" \
    --client-request-token $TOKEN \
    --targets repositoryName=$REPO,sourceReference=$BRANCH \
    > /dev/null

echo "Retrieve Pull Request ID"
MY_ARN=$(aws sts get-caller-identity | jq -r ".Arn")
PR_ID=$(aws codecommit list-pull-requests \
    --author-arn $MY_ARN \
    --pull-request-status OPEN \
    --repository-name $REPO \
    --query 'pullRequestIds[0]' --output text)

echo "Merging PR"
aws codecommit merge-pull-request-by-fast-forward \
    --pull-request-id $PR_ID \
    --repository-name $REPO \
    > /dev/null

echo "Script completed successfully!"
