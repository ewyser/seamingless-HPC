#!/bin/bash

############################################################################################################################################################
# DEFAULT BEHAVIOUR WHEN VM STARTS
############################################################################################################################################################

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

# Iteratively load docker image found in LOCAL_DIR 
echo "Loading Docker images..."
for image in $LOCAL_DIR/*.tar; do
    if [ -f "$image" ]; then  # Check if it's a file (not a directory)
        echo "Loading image: $image"
        sudo docker load -i "$image"
    fi
done

############################################################################################################################################################
# AUTOMATION 
############################################################################################################################################################

DATA_DIR="$LOCAL_DIR/data"
IMAGE_NAME="corium"
IMAGE_TAG="compute-engine"
# Run the Docker container with volume mount and environment variable
echo "Running container for image: $IMAGE_NAME"
CONTAINER_ID=$(docker run -v $DATA_DIR:/home/data -e VOLUME_MOUNT="/home/data" -d $IMAGE_NAME:$IMAGE_TAG)

# Check if container started successfully
if [ -z "$CONTAINER_ID" ]; then
    echo "Failed to start the container."
    exit 1
fi

# Execute a Julia command inside the running container
echo "Executing Julia command inside the container..."
docker exec -d "$CONTAINER_ID" julia --project=. -e 'using cORIUm; instr,ic = geoflow(10.0,5.0,512,5.0,1.0)'

# Wait for the container to finish (if it's a long-running job)
echo "Waiting for container $CONTAINER_ID to finish..."
docker wait "$CONTAINER_ID"

# Check logs from the container (optional, to see what happened)
echo "Container logs:"
docker logs "$CONTAINER_ID"

# Sync local data with bucket
gsutil -m rsync -r $LOCAL_DIR gs://$BUCKET_NAME

############################################################################################################################################################
# EXITING
############################################################################################################################################################

# Shutdown the VM after the container finishes
echo "Shutting down the VM..."
sudo shutdown -h now