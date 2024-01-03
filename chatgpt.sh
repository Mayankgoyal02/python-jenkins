#!/bin/bash

TEST_ID='13758845'

# Bitbucket repository details
BITBUCKET_REPO='https://bitbucket.org/your_username/your_repo.git'  # Replace with your Bitbucket repository URL
RAW_BASE_URL="${BITBUCKET_REPO}/raw/master/"

# BlazeMeter API details
FILES_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/files"
RUN_TEST_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/start"
USERNAME='ebf4a8d99d54eb292bcad9ce'
API_KEY='8be234d747e4d099e67040d248764c3a9d747b1c6df4c5003b813b8403b5e6c6e511ae77'

# Bitbucket credentials
BITBUCKET_USERNAME='your_bitbucket_username'
BITBUCKET_APP_PASSWORD='your_bitbucket_app_password'

# Fetch the list of files with .jmx and .csv extensions from Bitbucket
file_list=$(curl -s --user "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" "$RAW_BASE_URL" | grep -Eo 'href="([^"#]+\.jmx|[^"#]+\.csv)"' | cut -d'"' -f2)

# Display the list of files (optional)
echo "Files to be uploaded:"
echo "$file_list"

# Upload files to BlazeMeter
for file in $file_list; do
    file_url="$RAW_BASE_URL$file"
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
#   -X POST \
#   -H 'Content-Type: application/json' \
#   --user "$USERNAME:$API_KEY"
