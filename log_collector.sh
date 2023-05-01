#!/bin/bash

# Check if the required arguments are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <disto_api_key> <disto_project_id> [kubeconfig_location]"
  exit 1
fi

# Set the Disto API key and Disto project ID
DISTO_API_KEY="$1"
DISTO_PROJECT_ID="$2"

# Set the default kubeconfig location
KUBECONFIG_LOCATION="${3:-$HOME/.kube/config}"

# Check if the kubeconfig file exists
if [ ! -f "$KUBECONFIG_LOCATION" ]; then
  echo "Error: kubeconfig file not found at $KUBECONFIG_LOCATION"
  exit 1
fi

# Send a POST request with the kubeconfig file and the DISTO_PROJECT_ID
curl -X POST -H "Content-Type: multipart/form-data" \
     -F "kubeconfig=@$KUBECONFIG_LOCATION" \
     -F "project_id=$DISTO_PROJECT_ID" \
     http://localhost:5000/upload_kubeconfig

# Check if the POST request was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to send POST request with kubeconfig file"
  exit 1
fi

# Replace DISTO_API_KEY and DISTO_PROJECT_ID in the fluent-bit.yaml file
sed -i "s/DISTO_API_KEY/$DISTO_API_KEY/g" fluent-bit.yaml
sed -i "s/DISTO_PROJECT_ID/$DISTO_PROJECT_ID/g" fluent-bit.yaml

# Create the disto-fluentbit namespace
kubectl create namespace disto-fluentbit

# Apply the configuration
kubectl apply -f fluent-bit.yaml -n disto-fluentbit

# Check if the configuration was applied successfully
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply the configuration"
  exit 1
fi

echo "Successfully sent POST request with kubeconfig file and applied configuration"
