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
     https://backend.distoai.com/upload_kubeconfig

# Check if the POST request was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to upload kubeconfig file"
  exit 1
fi

# Determine the appropriate sed syntax based on the operating system
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS/BSD syntax
  SED_INPLACE="sed -i ''"
else
  # GNU/Linux syntax
  SED_INPLACE="sed -i"
fi

# Replace DISTO_API_KEY and DISTO_PROJECT_ID in the fluent-bit.yaml file
$SED_INPLACE "s|DISTO_API_KEY|$DISTO_API_KEY|g" fluent-bit.yaml
$SED_INPLACE "s|DISTO_PROJECT_ID|$DISTO_PROJECT_ID|g" fluent-bit.yaml

# Create the disto-fluentbit namespace
kubectl create namespace disto-fluentbit

# Apply the configuration
kubectl apply -f fluent-bit.yaml -n disto-fluentbit

# Check if the configuration was applied successfully
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply the configuration"
  exit 1
fi

echo "Successfully uploaded kubeconfig file and applied configuration"
