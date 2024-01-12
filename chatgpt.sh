#!/bin/bash

# Check if TEST_ID is provided as a command-line argument
if [ -z "${TEST_ID}" ]; then
    echo "Usage: $0 <TEST_ID>"
    exit 1
fi

# Jenkins build parameters
SELECT_FOLDER="${Select_Folder}"
SELECT_FILES="${Select_Files}"

# Check if build parameters are provided
if [ -z "$SELECT_FOLDER" ] || [ -z "$SELECT_FILES" ]; then
    echo "Build parameters not provided. Please provide values for 'Select_Folder' and 'Select_Files'."
    exit 1
fi

# Navigate to the specified folder
TARGET_FOLDER="${SELECT_FOLDER}_Script"
if [ ! -d "$TARGET_FOLDER" ]; then
    echo "Folder '$TARGET_FOLDER' not found."
    exit 1
fi

cd "$TARGET_FOLDER" || exit 1

# BlazeMeter API details
FILES_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/files"
USERNAME='aea9b231534f434c2e1448bf'
API_KEY='5006e34571c61320e68fe3a07fbe8fae31b0bb977ced85087e2bc1297c211035ae8a76ae'

# Display the list of files (optional)
echo "Files to be uploaded:"

# Array to store files
files_to_upload=()

# JMX file
JMX_FILE="${SELECT_FILES}.jmx"
if [ -f "$JMX_FILE" ]; then
    echo "$JMX_FILE"
    files_to_upload+=("$JMX_FILE")
else
    echo "JMX file '$JMX_FILE' not found in folder '$TARGET_FOLDER'."
    exit 1
fi

# usersDNU.csv file
USER_DNU_FILE="usersDNU.csv"
if [ -f "$USER_DNU_FILE" ]; then
    echo "$USER_DNU_FILE"
    files_to_upload+=("$USER_DNU_FILE")
else
    # Search for usersDNU.csv in the root directory
    cd ..
    if [ -f "$USER_DNU_FILE" ]; then
        echo "$USER_DNU_FILE"
        files_to_upload+=("$USER_DNU_FILE")
    else
        echo "File '$USER_DNU_FILE' not found in the target or root directory."
        exit 1
    fi
fi

# Upload files to BlazeMeter
for file in "${files_to_upload[@]}"; do
    # Upload each file individually using the provided curl command structure
    content_type="application/octet-stream"
    if [ "$file" == "$JMX_FILE" ]; then
        content_type="application/xml"
    fi

    upload_response=$(curl -sk "$FILES_URL" \
        -X POST \
        -H "Content-Type: $content_type" \
        -F "file=@$file" \
        --user "$USERNAME:$API_KEY"
    )

    echo "$file uploaded successfully."
done

# Uncomment the following lines if you want to run the test immediately after uploading files
# curl -sk "$RUN_TEST_URL" \
# -X POST \
# -H 'Content-Type: application/json' \
# --user "$USERNAME:$API_KEY"
