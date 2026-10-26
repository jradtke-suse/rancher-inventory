#!/bin/bash
set -euo pipefail

#  Purpose: to gather host CPU information from clusters managed by Rancher
#   Status: Work in Progress.  Script works but needs additional testing to ensure
#             different use-cases are accommodated.  Open an Issue/PR if you encounter problems
#     Note: This is *not* an official repo or script.  (it does rely on an official deployment though) 

# Function to check if required tools are installed
check_dependencies() {
    local missing_tools=()
    
    # Check for kubectl
    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    fi
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        missing_tools+=("curl")
    fi
    
    # Check for date command (should be available on all systems, but good to verify)
    if ! command -v date &> /dev/null; then
        missing_tools+=("date")
    fi
    
    # If any tools are missing, report and exit
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo "Error: The following required tools are not installed or not in PATH:"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        echo ""
        echo "Please install the missing tools and try again."
        exit 1
    fi
    
    echo "✓ All required tools are available"
}

run_from_web() {
  curl -o ./gather-info.sh https://raw.githubusercontent.com/jradtke-suse/rancher-inventory/refs/heads/main/Scripts/gather-info.sh 
  sh ./gather-info.sh 
}

# Check dependencies first
check_dependencies

# Let's make sure the correct KUBECONFIG and context in scpoe, then gather K8s information

# Validate/confirm current context is referring to Rancher Manager
echo ""
echo "Now showing available Kubernetes contexts:"
kubectl config get-contexts
echo ""

echo "Please confirm context (shown above with *) is correct."
echo "If context is not correct, press any key within 5 seconds to exit. Otherwise, script will proceed."
echo ""

# Function to read a single character with timeout
read_with_timeout() {
    if read -t 1 -n 1 -s key; then
        return 0  # Key was pressed
    else
        return 1  # Timeout occurred
    fi
}

# Countdown loop
for i in {5..1}; do
    echo -ne "\rTime remaining to cancel: $i seconds "
    
    if read_with_timeout; then
        echo -e "\n\nOperation cancelled by user input."
        exit 0
    fi
done
echo -e "\n\nWill now proceed with operation..."

# Validate what permissions/access this kubectl config has
echo "Now showing permissions and access"
kubectl auth can-i --list
echo 

# Create var for output
OUTPUT=rancher-systems-summary-$(date +%F).out

# Retrieve and apply the deployment
kubectl apply -f https://raw.githubusercontent.com/rancherlabs/support-tools/master/collection/rancher/v2.x/systems-information-v2/deploy.yaml

# Wait for the pod to reach Succeeded status
while [[ $(kubectl get pod rancher-systems-summary-pod -n cattle-system -o 'jsonpath={..status.phase}') != "Succeeded" ]]; do
  echo "Waiting for rancher-systems-summary-pod to complete..."
  sleep 5
done

# Grab the logs from the pod
kubectl logs pod/rancher-systems-summary-pod -n cattle-system > $OUTPUT

# Review the logs (and forward back to SUSE)
cat $OUTPUT
echo ""
echo "# Note:  You can find the output in file"
echo "cat $OUTPUT"
echo ""

# Clean up the pod
kubectl delete pod/rancher-systems-summary-pod -n cattle-system

