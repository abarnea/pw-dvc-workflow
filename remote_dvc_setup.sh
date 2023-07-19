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

if [ -d "pw-dvc-demo" ]
then
    rm -rf pw-dvc-demo
fi

URL="https://github.com/abarnea/pw-dvc-demo.git"

git clone $URL

cd pw-dvc-demo

source /home/$USER/storage_bucket.env

dvc remote modify --local mystorage credentialpath $STORAGE_PATH

dvc repro --pull

dvc push