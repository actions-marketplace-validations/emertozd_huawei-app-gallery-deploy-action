#!/bin/bash

set -o pipefail

# Required since https://github.blog/2022-04-12-git-security-vulnerability-announced
git config --global --add safe.directory $GITHUB_WORKSPACE

# Set debug mode if enabled
if [[ "${INPUT_DEBUG}" == "true" ]]; then
    set -x
    echo "🐛 Debug mode enabled"
fi

echo "🚀 Starting AppGallery deployment..."

# Validate required inputs
if [[ -z "${INPUT_CLIENT_ID}" ]]; then
    echo "❌ Client ID is required"
    exit 1
fi

if [[ -z "${INPUT_CLIENT_KEY}" ]]; then
    echo "❌ Client Key is required"
    exit 1
fi

if [[ -z "${INPUT_APP_ID}" ]]; then
    echo "❌ App ID is required"
    exit 1
fi

if [[ -z "${INPUT_FILE_PATH}" ]]; then
    echo "❌ File path is required"
    exit 1
fi

# Check if file exists
if [[ ! -f "${INPUT_FILE_PATH}" ]]; then
    echo "❌ File not found: ${INPUT_FILE_PATH}"
    exit 1
fi

# Run the Node.js deployment script
node $GITHUB_ACTION_PATH/index.js |
{
    UPLOAD_STATUS="failed"
    
    while read -r line; do
        echo $line
        
        if [[ $line == *"successfully uploaded"* ]]; then
            UPLOAD_STATUS="success"
            echo "UPLOAD_STATUS=success" >>"$GITHUB_OUTPUT"
        elif [[ $line == *"successfully submitted"* ]]; then
            echo "APP_SUBMIT_STATUS=success" >>"$GITHUB_OUTPUT"
        elif [[ $line == *"upload Failed"* ]] || [[ $line == *"❌"* ]]; then
            UPLOAD_STATUS="failed"
            echo "UPLOAD_STATUS=failed" >>"$GITHUB_OUTPUT"
            exit 1
        fi
    done
    
    # Ensure we set an output
    if [[ "${UPLOAD_STATUS}" == "success" ]]; then
        echo "✅ Deployment completed successfully"
        # Set a placeholder URL - in a real implementation, you'd extract this from the API response
        echo "APPGALLERY_CONSOLE_URL=https://developer.huawei.com/consumer/en/appgallery" >>"$GITHUB_OUTPUT"
    else
        echo "❌ Deployment failed"
        echo "UPLOAD_STATUS=failed" >>"$GITHUB_OUTPUT"
        exit 1
    fi
}