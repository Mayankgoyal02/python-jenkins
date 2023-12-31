#!/bin/bash

# Bitbucket repository details
USERNAME="your_username"
REPO_SLUG="your_repository_slug"
BRANCH="development"  # Replace with the branch you want to clone
BITBUCKET_ACCESS_TOKEN="your_bitbucket_access_token"

# Local directory to download the repository
LOCAL_DIR="local_clone_directory"

# Clone the repository into the local directory
git clone --branch "$BRANCH" "https://$USERNAME@bitbucket.org/$USERNAME/$REPO_SLUG.git" "$LOCAL_DIR"

# Move into the cloned repository directory
cd "$LOCAL_DIR"

# Get the names of all files
file_names=$(find . -type f)

# Print the file names
echo "Files in the repository:"
echo "$file_names"


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
