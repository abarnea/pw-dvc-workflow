#!/bin/bash

# git clone https://github.com/abarnea/pw-dvc-workflow.git

if [ -z $1 ]; then
  echo "Error: Please provide a repository name as an argument."
  exit 1
fi

REPO_NAME=$1
./launch_cluster.sh $REPO_NAME
