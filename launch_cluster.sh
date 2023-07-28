#!/bin/bash

# Get inputted variables from workflow.xml user interface
source inputs.sh

# Checks to see if a storage bucket path has been set.
# If it hasn't, runs the set_bucket script to set the storage path
# Else, continues with the script
if [ ! -f "storage_bucket.env" ]
then
    ./set_bucket.sh
fi

# Installs miniconda3 on remote machine with necessary packages from the
# install_python.sh script
bash python_installation/install_python.sh ${cluster_name}

# Sends storage bucket path environment file to remote machine
scp $( pwd )/storage_bucket.env ${hostname}@${cluster_name}.clusters.pw:/home/${USER}

# Starts the remote_dvc_setup script on the remote machine
ssh ${cluster_name}.clusters.pw ${hostname} bash -s < remote_dvc_setup.sh ${repo_name}