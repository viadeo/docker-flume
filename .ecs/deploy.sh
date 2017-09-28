#!/bin/bash -x

###############################################
#                 			      #
#                Parameters		      #
#                 			      #
###############################################

# Container name
CONTAINER_NAME="flume"

# Stack Name
STACK_NAME="ecs-${CONTAINER_NAME}"

# Cluster Name
CLUSTER_STACK_NAME="components-services-prod-ecs-backoffices-cluster"

# Task Name
TASK_NAME="task-${CONTAINER_NAME}"

# Local Docker image name
DOCKER_IMAGE_NAME="viadeo/docker_${CONTAINER_NAME}"

# Docker image name on ECR
DOCKER_IMAGE_NAME_ECR="062010136920.dkr.ecr.us-west-1.amazonaws.com/${DOCKER_IMAGE_NAME}"

### Container ###

# Memory (per default 512)
MEMORY=1024

# AWS Region
REGION=us-west-1

# LogGroup name
LOGGROUPNAME=awslogs-docker

###############################################
#					      #
# 		DO NOT MODIFY		      #
#					      #
###############################################

# S3 Bucket
S3_BUCKET="arn:aws:s3:::viadeo-infra/docker/BO/$S3_FOLDER/*"

# Deploy image to Docker Hub
eval $(aws ecr get-login --region 'us-west-1')
aws ecr create-repository --repository-name "viadeo/docker_${CONTAINER_NAME}" || true
docker push $DOCKER_IMAGE_NAME_ECR

# Ensure cloudwatch loggroup exists
aws logs create-log-group --log-group-name $LOGGROUPNAME --region $REGION || true

# jump into ecs repo
pushd .ecs/

# WAIT FOR FINAL STATE
while true; do
  EXIST_STACK=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --output text --query 'Stacks[0].{Status:StackStatus}')
  if echo $EXIST_STACK | grep -vq 'PROGRESS'; then
    break
  fi
  sleep 1
done

# IF Stack Failed -> Delete
if echo $EXIST_STACK | grep -q 'FAILED'; then
  aws cloudformation delete-stack --stack-name $STACK_NAME
  aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME
fi

#CAN UPDATE or CREATE STACK
if echo $EXIST_STACK | grep -q 'COMPLETE'; then
  CF_CMD=update-stack
  CF_FINAL_STATUS=stack-update-complete
else
  CF_CMD=create-stack
  CF_FINAL_STATUS=stack-create-complete
fi

aws cloudformation $CF_CMD \
  --stack-name $STACK_NAME \
  --template-body "$(<template.yml)"  \
  --parameters \
    ParameterKey=TaskName,ParameterValue=$TASK_NAME \
    ParameterKey=DockerImageName,ParameterValue=$DOCKER_IMAGE_NAME_ECR
aws cloudformation wait $CF_FINAL_STATUS --stack-name $STACK_NAME

popd
