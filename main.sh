#!/bin/bash

# Ensures that a repository to clone is provided by the user
# if [ -z $1 ]; then
#   echo "Error: Please provide a repository name as an argument."
#   exit 1
# fi

# Clone the pw-dvc-workflow DVC workflow wrapper Github repository
git clone https://github.com/abarnea/pw-dvc-workflow.git .

# Launches the cluster startup script
./launch_cluster.sh
