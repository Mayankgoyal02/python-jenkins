#!/bin/bash

# Check if TEST_ID is provided as a command-line argument
if [ -z "${TEST_ID}" ]; then
    echo "Usage: $0 <TEST_ID>"
    exit 1
fi

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

# BlazeMeter API details
FILES_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/files"
USERNAME='aea9b231534f434c2e1448bf'
API_KEY='5006e34571c61320e68fe3a07fbe8fae31b0bb977ced85087e2bc1297c211035ae8a76ae'

# Display the list of files (optional)
echo "Files to be uploaded:"

# Navigate to the specified subfolder
TARGET_SUB_FOLDER="$SELECT_FOLDER"
if [ ! -d "$TARGET_SUB_FOLDER" ]; then
    echo "Subfolder '$TARGET_SUB_FOLDER' not found."
    exit 1
fi

cd "$TARGET_SUB_FOLDER" || exit 1

# Iterate through all .jmx and .csv files in the subfolder
for FILE in *.jmx *.csv; do
    if [ -f "$FILE" ]; then
        echo "Uploading $FILE..."
        upload_response=$(curl -sk "$FILES_URL" \
            -X POST \
            -F "file=@$FILE" \
            --user "$USERNAME:$API_KEY"
        )

        echo "$FILE uploaded successfully."
    else
        echo "File '$FILE' not found in subfolder."
        exit 1
    fi
done

# Uncomment the following lines if you want to run the test immediately after uploading files
# curl -sk "$RUN_TEST_URL" \
# -X POST \
# -H 'Content-Type: application/json' \
# --user "$USERNAME:$API_KEY"
