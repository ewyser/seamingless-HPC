#!/bin/bash
BUCKET_NAME="your-bucket-name"
LOCAL_DIR="/home/dev/inout-transfer"

# Install gcsfuse if not installed
if ! command -v gcsfuse &>/dev/null; then
    echo "gcsfuse could not be found, installing..."

    # Enable EPEL repository
    sudo yum install -y epel-release

    # Install dependencies for gcsfuse
    sudo yum install -y fuse

    # Install gcsfuse
    sudo curl -sSL https://github.com/GoogleCloudPlatform/gcsfuse/releases/download/v0.38.1/gcsfuse-0.38.1-0.x86_64.rpm -o gcsfuse.rpm
    sudo yum localinstall -y gcsfuse.rpm
fi

# Mount the bucket using gcsfuse
mkdir -p $MOUNT_POINT
gcsfuse $BUCKET_NAME $MOUNT_POINT