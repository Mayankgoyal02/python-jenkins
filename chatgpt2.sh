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

# Check if the JMX file exists
JMX_FILE="${SELECT_FILES}.jmx"
if [ ! -f "$JMX_FILE" ]; then
    echo "JMX file '$JMX_FILE' not found in folder '$TARGET_FOLDER'."
    exit 1
fi

# BlazeMeter API details
FILES_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/files"
USERNAME='aea9b231534f434c2e1448bf'
API_KEY='5006e34571c61320e68fe3a07fbe8fae31b0bb977ced85087e2bc1297c211035ae8a76ae'

# Display the list of files (optional)
echo "Files to be uploaded:"
echo "$JMX_FILE"
echo "userDNU.csv"

# Upload files to BlazeMeter
for file in "$JMX_FILE" "userDNU.csv"; do
    # Upload each file individually using the provided curl command structure
    upload_response=$(curl -sk "$FILES_URL" \
        -X POST \
        -F "file=@$file" \
        --user "$USERNAME:$API_KEY"
    )
done

# Uncomment the following lines if you want to run the test immediately after uploading files
# curl -sk "$RUN_TEST_URL" \
# -X POST \
# -H 'Content-Type: application/json' \
# --user "$USERNAME:$API_KEY"
