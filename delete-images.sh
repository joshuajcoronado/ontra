#!/bin/bash

# Check if both repository name and region are provided as arguments
if [ $# -lt 2 ]; then
  echo "Usage: $0 <repository-name> <region>"
  exit 1
fi

# Extract repository name and region from command-line arguments
repository_name="$1"
region="$2"

# List all image IDs in the repository and parse the JSON
image_ids_json=$(aws ecr list-images --repository-name "$repository_name" --query 'imageIds[*]' --output json --region "$region")

# Use jq to extract the individual image IDs (digests or tags) and iterate over them
for image_id in $(echo "$image_ids_json" | jq -r '.[] | .imageDigest, .imageTag'); do
    # Check if the image ID is not null
    if [ "$image_id" != "null" ]; then
        # Determine whether it's an imageDigest or imageTag
        if [[ "$image_id" == sha256* ]]; then
            echo "Deleting image with digest: $image_id"
            aws ecr batch-delete-image --repository-name "$repository_name" --image-ids imageDigest="$image_id" --region "$region"
        else
            echo "Deleting image with tag: $image_id"
            aws ecr batch-delete-image --repository-name "$repository_name" --image-ids imageTag="$image_id" --region "$region"
        fi
    fi
done
