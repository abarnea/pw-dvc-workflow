#!/bin/bash

# if [ -z $1 ]; then
#   echo "Error: Please provide a repository name as an argument."
#   exit 1
# fi

git clone https://github.com/abarnea/pw-dvc-workflow.git .

./launch_cluster.sh
