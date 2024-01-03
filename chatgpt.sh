#!/bin/bash

# Set your Bitbucket credentials and repository information
USERNAME="your_username"
REPO_SLUG="your_repository_slug"
API_TOKEN="your_api_token"

# Bitbucket API endpoint for listing repository contents
API_ENDPOINT="https://api.bitbucket.org/2.0/repositories/$USERNAME/$REPO_SLUG/src"

# Make the API request to get the file names
response=$(curl -s -H "Authorization: Bearer $API_TOKEN" "$API_ENDPOINT")

# Check if the request was successful (HTTP status code 200)
if [[ "$(echo "$response" | grep -o '"type": "[^"]*"' | cut -d '"' -f4)" == "error" ]]; then
    echo "Error: $(echo "$response" | grep -o '"message": "[^"]*"' | cut -d '"' -f4)"
else
    # Extract file names from the JSON response
    file_names=$(echo "$response" | grep -o '"path": "[^"]*"' | cut -d '"' -f4)

    # Print the file names
    echo "Files in the repository:"
    echo "$file_names"
fi


#!/bin/bash

TEST_ID='13788085'

# Bitbucket repository details
BITBUCKET_REPO='https://bitbucket.corp.chartercom.com/scm/smt/mobile-it-devops-cicd.git'  # Replace with your Bitbucket repository URL
RAW_BASE_URL="${BITBUCKET_REPO}/raw/development/performance_test/"

# BlazeMeter API details
FILES_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/files"
RUN_TEST_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/start"
USERNAME='aea9b231534f434c2e1448bf'
API_KEY='5006e34571c61320e68fe3a07fbe8fae31b0bb977ced85087e2bc1297c211035ae8a76ae'

# Bitbucket access token
BITBUCKET_ACCESS_TOKEN='NTI3OTkzNTYzOTQxOjz3y4JI9MERpV0OPebp3isLwxg2'

# Fetch the list of files with .jmx and .csv extensions from Bitbucket
file_list=$(curl -v -s --header "Authorization: Bearer $BITBUCKET_ACCESS_TOKEN" "$RAW_BASE_URL" | grep -Eo 'href="([^"#]+\.jmx|[^"#]+\.csv)"' | cut -d'"' -f2)

# Display the list of files (optional)
echo "Files to be uploaded:"
echo "$file_list"

# Upload files to BlazeMeter
for file in $file_list; do
    file_url="$RAW_BASE_URL$file"
    filename=$(basename "$file")

    # Upload each file individually using the provided curl command structure
    upload_response=$(curl -v -sk "$FILES_URL" \
        -X POST \
        -F "file=@$filename" \
        --user "$USERNAME:$API_KEY"
    )

    echo "Upload response for $filename:"
    echo "$upload_response"
done

# Uncomment the following lines if you want to run the test immediately after uploading files
# curl -v -sk "$RUN_TEST_URL" \
#   -X POST \
#   -H 'Content-Type: application/json' \
#   --user "$USERNAME:$API_KEY"
