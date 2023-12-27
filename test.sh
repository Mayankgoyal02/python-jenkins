#!/bin/bash
 
# Check if BLAZEMETER_TEST_ID is provided as an environment variable
if [ -z "${BLAZEMETER_TEST_ID}" ]; then
 echo "Error: BLAZEMETER_TEST_ID environment variable is not set."
 exit 1
fi
 
TEST_ID="${BLAZEMETER_TEST_ID}"
 
JMX_FILE='performancetesting.jmx'
USER_CSV='user.csv'
DATA_CSV='data.csv'
FILES_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/files"
RUN_TEST_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/start"
USERNAME='ebf4a8d99d54eb292bcad9ce'
API_KEY='8be234d747e4d099e67040d248764c3a9d747b1c6df4c5003b813b8403b5e6c6e511ae77'
 
# Upload the JMX file
curl -sk "$FILES_URL" \
 -X POST \
 -F "file=@$JMX_FILE" \
 --user "$USERNAME:$API_KEY"
 
curl -sk "$FILES_URL" \
 -X POST \
 -F "file=@$USER_CSV" \
 --user "$USERNAME:$API_KEY"
 
curl -sk "$FILES_URL" \
 -X POST \
 -F "file=@$DATA_CSV" \
 --user "$USERNAME:$API_KEY"
 
# Uncomment the following lines if you want to run the test immediately after uploading files
# curl -sk "$RUN_TEST_URL" \
#  -X POST \
#  -H 'Content-Type: application/json' \
#  --user "$USERNAME:$API_KEY"
