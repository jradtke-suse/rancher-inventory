#!/bin/bash

# Purpose: to gather host CPU information from clusters managed by Rancher
#  Status: Work in Progress.  Script works but needs additional testing to ensure
#            different use-cases are accommodated.  Open an Issue/PR if you encounter problems
#    Note: This is *not* an official repo or script.  (it does rely on an official deployment though) 

# curl -o ./gather-info.sh https://raw.githubusercontent.com/jradtke-suse/rancher-inventory/refs/heads/main/Scripts/gather-info.sh 
# sh ./gather-info.sh 

# Make sure you have the correct KUBECONFIG and context in scpoe, then run the following commands:
# Manual Steps
# Validate/confirm current context is pointing to Rancher Manager

echo "Now showing available Kubernetes contexts:"
kubectl config get-contexts

echo ""
echo "Please confirm context is correct."
echo "If context is not correct, press any key within 5 seconds to exit..."
# -n 1 : read 1 character
# -s   : do not echo input
# -t 5 : wait up to 5 seconds
if read -n 1 -s -t 5; then
    echo "Key pressed. Exiting."
    echo ""
    echo "run: kubectl config use-context <correct context> "
    echo "to use the correct context."
    echo ""
    exit 0
else
    echo "No key pressed. Continuing..."
fi

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

# Clean up the pod
kubectl delete pod/rancher-systems-summary-pod -n cattle-system

