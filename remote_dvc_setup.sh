#!/bin/bash

# Set error message quitting
set -e

# Echo line number of error and exits with code 1
handle_error() {
    echo "An error occurred in line $1. Exiting."
    exit 1
}

# Set the miniconda directory and activates the dvc conda environment
miniconda_dir="${resource_workdir}/.miniconda3"
source ${miniconda_dir}/etc/profile.d/conda.sh
conda activate dvc_env

# Downgrade version of google-auth-oauthlib to 0.5.3 as
# Normal installation doesn't work correctly
pip install google-auth-oauthlib==0.5.3

# Get inputted variables from workflow.xml user interface
source inputs.sh

# Deletes a cloned copy of the input repository if it exists
# Otherwise, continues
if [ -d $repo_name ]
then
    rm -rf $repo_name
fi

# Grabs the inputted Github repository
URL="git@github.com:/${git_username}/${repo_name}.git"

# Clone the inputted repository from SSH URL
git clone $URL

# Sets the current directory to the cloned repository
cd $repo_name

# Sets the cloud storage bucket path
source ${resource_workdir}/storage_bucket.env

# Modifies the DVC remote storage path and credentials to account for the
# Cluster configuration
dvc remote modify --local ${storage_name} credentialpath ${bucket_storage_path}

# Pulls any new DVC data and reproduces the ML model training pipeline
dvc repro --pull

# Push the newly trained ML model back to cloud storage according to the
# initially set cloud storage bucket path
dvc push