#!/bin/bash

# Get inputted variables from workflow.xml user interface
source inputs.sh

# Checks to see if a storage bucket path has been set.
# If it hasn't, runs the set_bucket script to set the storage path
# Else, continues with the script
# if [ ! -f "storage_bucket.env" ]
# then
#     ./set_bucket.sh
# fi

# Installs miniconda3 on remote machine with necessary packages from the
# install_python.sh script
bash python_installation/install_python.sh ${resource_name}

echo "Point A"

# Sends inputs environment file to remote machine
scp $( pwd )/inputs.sh ${hostname}@${resource_name}.clusters.pw:${resource_workdir}

echo "Point B"

# Starts the remote_dvc_setup script on the remote machine
ssh ${resource_name}.clusters.pw ${hostname} bash -s < remote_dvc_setup.sh ${git_repo_name}

echo "Point C"