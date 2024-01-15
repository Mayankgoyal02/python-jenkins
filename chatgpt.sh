#!/bin/bash

# Check if TEST_ID is provided as a command-line argument
if [ -z "${TEST_ID}" ]; then
    echo "Usage: $0 <TEST_ID>"
    exit 1
fi

# Jenkins build parameters
SELECT_FOLDER="${Select_Environment}"
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


# JMX file
JMX_FILE="${SELECT_FILES}.jmx"
if [ -f "$JMX_FILE" ]; then
    # ... (previous code for uploading JMX file remains unchanged)

    # Check the JMX file name and find the corresponding second CSV file
    if [[ "$JMX_FILE" == "SpectrumMobile QA2_Telesales_Retail_PiNxt.jmx" ]]; then
        SECOND_CSV_FILE="S02_SpectrumAccountNumber_Telesales_QA2_PiNxt.csv"
    elif [[ "$JMX_FILE" == "SpectrumMobile_QA2_Retail_ActivationFlow_PiNxt.jmx" ]]; then
        SECOND_CSV_FILE="S02_SpectrumAccountNumber_Retail_QA2_Pinxt.csv"
    else
        echo "No second CSV file specified for '$JMX_FILE'."
        exit 1
    fi

    # Check for the second CSV file in the current and target directories
    if [ -f "$SECOND_CSV_FILE" ]; then
        echo "Uploading $SECOND_CSV_FILE..."
        upload_response=$(curl -sk "$FILES_URL" \
            -X POST \
            -F "file=@$SECOND_CSV_FILE" \
            --user "$USERNAME:$API_KEY"
        )

        echo "$SECOND_CSV_FILE uploaded successfully."
    else
        cd "$TARGET_FOLDER" || exit 1
        if [ -f "$SECOND_CSV_FILE" ]; then
            echo "Uploading $SECOND_CSV_FILE..."
            upload_response=$(curl -sk "$FILES_URL" \
                -X POST \
                -F "file=@$SECOND_CSV_FILE" \
                --user "$USERNAME:$API_KEY"
            )

            echo "$SECOND_CSV_FILE uploaded successfully."
        else
            echo "Second CSV file '$SECOND_CSV_FILE' not found in the current or target directory."
            exit 1
        fi
    fi

else
    echo "JMX file '$JMX_FILE' not found in folder '$TARGET_FOLDER'."
    exit 1
fi

# ... (remaining code for uploading usersDNU.csv remains unchanged)


# usersDNU.csv file
USER_DNU_FILE="usersDNU.csv"
if [ -f "$USER_DNU_FILE" ]; then
    echo "Uploading $USER_DNU_FILE..."
    upload_response=$(curl -sk "$FILES_URL" \
        -X POST \
        -F "file=@$USER_DNU_FILE" \
        --user "$USERNAME:$API_KEY"
    )

    echo "$USER_DNU_FILE uploaded successfully."
else
    # Search for usersDNU.csv in the root directory
    cd ..
    if [ -f "$USER_DNU_FILE" ]; then
        echo "Uploading $USER_DNU_FILE..."
        upload_response=$(curl -sk "$FILES_URL" \
            -X POST \
            -F "file=@$USER_DNU_FILE" \
            --user "$USERNAME:$API_KEY"
        )

        echo "$USER_DNU_FILE uploaded successfully."
    else
        echo "File '$USER_DNU_FILE' not found in the target or root directory."
        exit 1
    fi
fi

# Uncomment the following lines if you want to run the test immediately after uploading files
# curl -sk "$RUN_TEST_URL" \
# -X POST \
# -H 'Content-Type: application/json' \
# --user "$USERNAME:$API_KEY"
# S02_ManageAccountsQA2MMR.csv
# S02_SpectrumAccountNumber_Retail_QA2_Pinxt.csv
# S02_SpectrumAccountNumber_Telesales_QA2_PiNxt.csv

# SpectrumMobile QA2_BYOD_PiNxt.jmx

# SpectrumMobile QA2_MANAGEACCOUNTS_PiNxt.jmx

# SpectrumMobile QA2_Telesales_Retail_PiNxt.jmx

# SpectrumMobile_QA2_NDEL_PiNxt.jmx

# SpectrumMobile_QA2_Retail_ActivationFlow_PiNxt.jmx
