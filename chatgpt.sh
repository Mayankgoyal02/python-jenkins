#!/bin/bash

# Check if TEST_ID is provided as a command-line argument
if [ -z "${TEST_ID}" ]; then
 echo "Usage: $0 <TEST_ID>"
 exit 1
fi

# BlazeMeter API details
FILES_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/files"
RUN_TEST_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/start"
USERNAME='aea9b231534f434c2e1448bf'
API_KEY='5006e34571c61320e68fe3a07fbe8fae31b0bb977ced85087e2bc1297c211035ae8a76ae'

# Fetch the list of files with .jmx and .csv extensions from the current directory
file_list=$(ls | grep -E '\.jmx$|\.csv$')

# Display the list of files (optional)
echo "Files to be uploaded:"
echo "$file_list"

# Upload files to BlazeMeter
for file in $file_list; do
 filename=$(basename "$file")

 # Upload each file individually using the provided curl command structure
 upload_response=$(curl -sk "$FILES_URL" \
  -X POST \
  -F "file=@$filename" \
  --user "$USERNAME:$API_KEY"
 )
done

# Uncomment the following lines if you want to run the test immediately after uploading files
# curl -sk "$RUN_TEST_URL" \
# -X POST \
# -H 'Content-Type: application/json' \
# --user "$USERNAME:$API_KEY"
