#!/bin/bash

source inputs.sh

if [ ! -f "storage_bucket.env" ]
then
    ./set_bucket.sh
fi

bash python_installation/install_python.sh $clustername

scp $( pwd )/storage_bucket.env ${hostname}@${clustername}.clusters.pw:/home/${USER}

ssh ${clustername}.clusters.pw ${hostname} bash -s < remote_dvc_setup.sh $REPO_NAME