#!/bin/bash

# Set error message quitting
set -e

# Echo line number of error and exits with code 1
handle_error() {
    echo "An error occurred in line $1. Exiting."
    exit 1
}

# Get inputted variables from workflow.xml user interface
source inputs.sh

# Set the miniconda directory and activates the dvc conda environment
miniconda_dir="${resource_workdir}/.miniconda3"
source ${miniconda_dir}/etc/profile.d/conda.sh
conda activate dvc_env

# Downgrade version of google-auth-oauthlib to 0.5.3 as
# Normal installation doesn't work correctly
pip install google-auth-oauthlib==0.5.3

# Grabs the inputted Github repository
URL="git@github.com:/${git_username}/${git_repo_name}.git"

# Clone the inputted repository from SSH URL if it doesn't already exist
if [ ! -d $git_repo_name ]
then
    git clone $URL
fi

# Sets the current directory to the cloned repository
cd $git_repo_name

# Sets the cloud storage bucket path
# source ${resource_workdir}/storage_bucket.env

# Modifies the DVC remote storage path and credentials to account for the
# Cluster configuration
dvc remote modify --local ${storage_name} credentialpath ${storage_bucket_path}

# Pulls any new DVC data and reproduces the ML model training pipeline
dvc repro --pull

if [ $model_setting == "train" ]
then
    # Push the newly trained ML model back to cloud storage according to the
    # initially set cloud storage bucket path
    dvc push
elif [ $model_setting == "run" ]
then
    # Runs the user configured script
    bash $model_user_script_name
fi
