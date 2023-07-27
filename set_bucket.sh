#!/bin/bash

source inputs.sh

# read -sp 'Please enter the absolute path of your remote storage bucket: ' storage_path

if [ -f "storage_bucket.env" ]
then
    rm -f storage_bucket.env
fi

touch storage_bucket.env
echo "STORAGE_PATH=\"${STORAGE_PATH}\"" > storage_bucket.env

echo
echo "Thank you. Your storage bucket path has been set."
