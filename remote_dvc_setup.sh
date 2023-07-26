#!/bin/bash

set -e

handle_error() {
    echo "An error occurred in line $1. Exiting."
    exit 1
}

miniconda_dir="/home/${USER}/.miniconda3"
source ${miniconda_dir}/etc/profile.d/conda.sh
conda activate dvc_env

pip install google-auth-oauthlib==0.5.3

REPO_NAME=$1

if [ -d $REPO_NAME ]
then
    rm -rf $REPO_NAME
fi

URL="https://github.com/abarnea/${REPO_NAME}.git"

git clone $URL

cd $REPO_NAME

source /home/$USER/storage_bucket.env

STORAGE_NAME="storage"

dvc remote modify --local $STORAGE_NAME credentialpath $STORAGE_PATH

dvc repro --pull

dvc push