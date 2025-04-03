#!/bin/bash

# Define variables
BUCKET_NAME="hydrorisk-bucket"
LOG_FILE="/home/dev/startup_VM.log"
LOCAL_DIR="/home/dev/IO"

# Ensure the log file exists by creating an empty log file if not present
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"  # Create the log file if it doesn't exist
fi

# Log the start of the script execution
{
  echo "Starting script execution at $(date +"%Y%m%d_%H%M%S")"
  echo "--------------------------------------------------------------------------------"
} >> "$LOG_FILE"

# Ensure the LOCAL_DIR exists
if [ -d "$LOCAL_DIR" ]; then
    # If directory exists, delete and recreate it
    echo "Directory $LOCAL_DIR exists, removing and recreating it..." >> "$LOG_FILE"
    rm -rf "$LOCAL_DIR"  # Delete existing directory and its contents
    mkdir -p "$LOCAL_DIR"  # Recreate the LOCAL_DIR
    echo "Directory $LOCAL_DIR recreated successfully." >> "$LOG_FILE"
else
    # If directory doesn't exist, create it
    echo "Directory $LOCAL_DIR does not exist. Creating it..." >> "$LOG_FILE"
    mkdir -p "$LOCAL_DIR"  # Create LOCAL_DIR if it doesn't exist
    echo "Directory $LOCAL_DIR created successfully." >> "$LOG_FILE"
fi

# Log completion of the directory creation process
echo "Directory creation process completed." >> "$LOG_FILE"

# Install Google Cloud SDK and gsutil if not installed
if ! command -v gsutil &>/dev/null; then
    echo "gsutil could not be found, installing..." >> "$LOG_FILE"

    # Enable EPEL repository if not already enabled
    sudo yum install -y epel-release

    # Install dependencies
    sudo yum install -y curl

    # Install Google Cloud SDK (which includes gsutil)
    curl -sSL https://sdk.cloud.google.com | bash

    # Optionally ask user to restart the shell or manually handle it later.
    echo "Google Cloud SDK installed. Please restart your shell to update your environment." >> "$LOG_FILE"
fi

# Sync the bucket with the local directory
echo "Syncing Google Cloud Storage bucket $BUCKET_NAME to $LOCAL_DIR" >> "$LOG_FILE"
gsutil -m rsync -r gs://$BUCKET_NAME $LOCAL_DIR >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    echo "Error syncing bucket" >> "$LOG_FILE"
    exit 1
fi

# Iteratively load Docker images found in LOCAL_DIR
echo "Loading Docker images..." >> "$LOG_FILE"
image_found=false
for image in $LOCAL_DIR/*.tar; do
    if [ -f "$image" ]; then  # Check if it's a file (not a directory)
        image_found=true
        echo "Loading image: $image" >> "$LOG_FILE"
        sudo docker load -i "$image" >> "$LOG_FILE" 2>&1
        if [ $? -ne 0 ]; then
            echo "Error loading image: $image" >> "$LOG_FILE"
            continue  # Skip to the next image
        fi
    fi
done

if ! $image_found; then
    echo "No Docker images found in $LOCAL_DIR" >> "$LOG_FILE"
fi

echo "Script execution completed." >> "$LOG_FILE"
