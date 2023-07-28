#!/bin/bash

# Get inputted variables from workflow.xml user interface
source inputs.sh

# Privately read the absolute path of the remote storage bucket
# read -sp 'Please enter the absolute path of your remote storage bucket: ' storage_path

# Checks to see if a storage bucket path has been set. Deletes it if so,
# as the newly inputted path will be given priority. Otherwise, continues
if [ -f "storage_bucket.env" ]
then
    rm -f storage_bucket.env
fi

# Create the storage bucket environment file to be read
touch storage_bucket.env

# Sets the STORAGE_PATH environment variable and sends it into the storage
# bucket environment file
echo "STORAGE_PATH=\"${storage_path}\"" > storage_bucket.env

# Thank you message
echo
echo "Thank you. Your storage bucket path has been set."
