#!/bin/bash
BUCKET_NAME="hydrorisk-bucket"
LOCAL_DIR="/home/dev/inout-transfer"

# Install Google Cloud SDK and gsutil if not installed
if ! command -v gsutil &>/dev/null; then
    echo "gsutil could not be found, installing..."

    # Enable EPEL repository if not already enabled
    sudo yum install -y epel-release

    # Install dependencies
    sudo yum install -y curl

    # Install Google Cloud SDK (which includes gsutil)
    curl -sSL https://sdk.cloud.google.com | bash

    # Restart shell to ensure gcloud/gsutil is in the path
    exec -l $SHELL
fi

# Check if LOCAL_DIR exists, and create it if it does not
if [ ! -d "$LOCAL_DIR" ]; then
    echo "Directory $LOCAL_DIR does not exist. Creating it..."
    mkdir -p "$LOCAL_DIR"
fi

# Sync the bucket with the local directory
echo "Syncing Google Cloud Storage bucket $BUCKET_NAME to $LOCAL_DIR"
gsutil -m rsync -r gs://$BUCKET_NAME $LOCAL_DIR

echo "Loading Docker images..."
for image in $LOCAL_DIR/*.tar; do
    if [ -f "$image" ]; then  # Check if it's a file (not a directory)
        echo "Loading image: $image"
        sudo docker load -i "$image"
    fi
done