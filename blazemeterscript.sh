# API_URL='https://a.blazemeter.com/api/v4/tests'
# FILES_URL='https://a.blazemeter.com/api/v4/tests/1234567/files'
# USERNAME='ebf4a8d99d54eb292bcad9ce'
# API_KEY='8be234d747e4d099e67040d248764c3a9d747b1c6df4c5003b813b8403b5e6c6e511ae77'
# TEST_NAME='boss'
# CONFIG_JSON='{"type": "taurus", "filename": "performancetesting.jmx", "testMode": "script", "scriptType": "jmeter"}'

# # Create a test
# curl -sk "$API_URL" \
#     -X POST \
#     -H 'Content-Type: application/json' \
#     --user "$USERNAME:$API_KEY" \
#     -d "{\"name\": \"$TEST_NAME\", \"configuration\": $CONFIG_JSON}"

# # Upload the JMX file
# curl -sk "$FILES_URL" \
#     -X POST \
#     -F "file=@performancetesting.jmx" \
#     --user "$USERNAME:$API_KEY"

#!/bin/bash
FILES_URL='https://a.blazemeter.com/api/v4/tests/13758845/files'
USERNAME='ebf4a8d99d54eb292bcad9ce'
API_KEY='8be234d747e4d099e67040d248764c3a9d747b1c6df4c5003b813b8403b5e6c6e511ae77'

# Upload the JMX file
curl -sk "$FILES_URL" \
    -X POST \
    -F "file=@performancetesting.jmx" \
    --user "$USERNAME:$API_KEY"

curl -sk "$FILES_URL" \
    -X POST \
    -F "file=@user.csv" \
    --user "$USERNAME:$API_KEY"  

curl -sk "$FILES_URL" \
    -X POST \
    -F "file=@data.csv" \
    --user "$USERNAME:$API_KEY"      

