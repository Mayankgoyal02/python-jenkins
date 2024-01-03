$ ./get-pf.sh
*   Trying 142.136.245.35:443...
* Connected to bitbucket.corp.chartercom.com (142.136.245.35) port 443 (#0)
* ALPN: offers h2
* ALPN: offers http/1.1
} [5 bytes data]
* [CONN-0-0][CF-SSL] TLSv1.3 (OUT), TLS handshake, Client hello (1):
} [512 bytes data]
* [CONN-0-0][CF-SSL] TLSv1.3 (IN), TLS handshake, Server hello (2):
{ [91 bytes data]
* [CONN-0-0][CF-SSL] TLSv1.2 (IN), TLS handshake, Certificate (11):
{ [6221 bytes data]
* [CONN-0-0][CF-SSL] TLSv1.2 (IN), TLS handshake, Server key exchange (12):
{ [333 bytes data]
* [CONN-0-0][CF-SSL] TLSv1.2 (IN), TLS handshake, Server finished (14):
{ [4 bytes data]
* [CONN-0-0][CF-SSL] TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
} [70 bytes data]
* [CONN-0-0][CF-SSL] TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
} [1 bytes data]
* [CONN-0-0][CF-SSL] TLSv1.2 (OUT), TLS handshake, Finished (20):
} [16 bytes data]
* [CONN-0-0][CF-SSL] TLSv1.2 (IN), TLS handshake, Finished (20):
{ [16 bytes data]
* SSL connection using TLSv1.2 / ECDHE-RSA-AES128-GCM-SHA256
* ALPN: server did not agree on a protocol. Uses default.
* Server certificate:
*  subject: C=US; ST=Missouri; L=St. Louis; O=Charter Communications Operating, LLC; OU=IT Architecture; CN=bitbucket.corp.chartercom.com
*  start date: Feb  2 18:59:16 2023 GMT
*  expire date: Feb  1 18:59:16 2025 GMT
*  issuer: DC=com; DC=chartercom; DC=corp; CN=Charter Communications Issuing CA1
*  SSL certificate verify result: self signed certificate in certificate chain (19), continuing anyway.
} [5 bytes data]
> GET /scm/smt/mobile-it-devops-cicd.git/raw/development/performance_test/ HTTP/1.1
> Host: bitbucket.corp.chartercom.com
> User-Agent: curl/7.87.0
> Accept: */*
> Authorization: Bearer NTI3OTkzNTYzOTQxOjz3y4JI9MERpV0OPebp3isLwxg2
>
{ [5 bytes data]
* Mark bundle as not supporting multiuse
< HTTP/1.1 501
< Date: Wed, 03 Jan 2024 11:32:12 GMT
< Server: Apache/2.4.6 (Red Hat Enterprise Linux) OpenSSL/1.0.2k-fips
< X-AREQUESTID: *3ZQ4P8x692x3876288x3
< X-AUSERID: 75026
< X-AUSERNAME: P3214465
< X-ASESSIONID: jwvu57
< Cache-Control: private, no-cache
< Pragma: no-cache
< x-xss-protection: 1; mode=block
< x-frame-options: SAMEORIGIN
< x-content-type-options: nosniff
< Set-Cookie: BITBUCKETSESSIONID=D041A87159A2DE6F1BEC891738D04F82; Max-Age=1209600; Expires=Wed, 17 Jan 2024 11:32:13 GMT; Path=/; Secure; HttpOnly
< Connection: close
< Transfer-Encoding: chunked
<
{ [5 bytes data]
* Closing connection 0
} [5 bytes data]
* [CONN-0-0][CF-SSL] TLSv1.2 (OUT), TLS alert, close notify (256):
} [2 bytes data]
Files to be uploaded:


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
