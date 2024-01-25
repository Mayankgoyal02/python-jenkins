#!/bin/bash

# Check if TEST_ID is provided as a command-line argument
if [ -z "${TEST_ID}" ]; then
    echo "Usage: $0 <TEST_ID>"
    exit 1
fi

# BlazeMeter API details
FILES_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/files"
DELETE_FILE_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/delete-file"
USERNAME='aea9b231534f434c2e1448bf'
API_KEY='5006e34571c61320e68fe3a07fbe8fae31b0bb977ced85087e2bc1297c211035ae8a76ae'

# Get the list of files
response=$(curl -sk "${FILES_URL}" --user "$USERNAME:$API_KEY")

# Extract names into an array, handling names with spaces
IFS=$'\n' read -r -d '' -a names_array <<< "$(echo "$response" | grep -o '"name": "[^"]*' | cut -d'"' -f4)"

# Check if there are files to delete
if [ ${#names_array[@]} -eq 0 ]; then
    echo "No files present to delete."
else
    # Print the array
    echo "Files to be deleted: ${names_array[@]}"

    # Loop through the array and delete each file
    for file_name in "${names_array[@]}"; do
        echo "Deleting file: $file_name"
        # Use curl to send a POST request with a JSON payload
        curl -X POST -sk "${DELETE_FILE_URL}" \
            -H "Content-Type: application/json" \
            --user "$USERNAME:$API_KEY" \
            -d "{\"fileName\":\"$file_name\"}"
    done
fi

# Continue with the rest of the original script

# Jenkins build parameters
SELECT_ENVIRONMENT="${Select_Environment}"
SELECT_FOLDER="${Select_Files}"

# Check if build parameters are provided
if [ -z "$SELECT_ENVIRONMENT" ] || [ -z "$SELECT_FOLDER" ]; then
    echo "Build parameters not provided. Please provide values for 'Select_Environment' and 'Select_Files'."
    exit 1
fi

# Navigate to the specified environment folder
TARGET_ENV_FOLDER="${SELECT_ENVIRONMENT}_Script"
if [ ! -d "$TARGET_ENV_FOLDER" ]; then
    echo "Folder '$TARGET_ENV_FOLDER' not found."
    exit 1
fi

cd "$TARGET_ENV_FOLDER" || exit 1

# ... rest of the original script
