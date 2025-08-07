#!/bin/bash

# Purpose: to gather host CPU information from clusters managed by Rancher

# Make sure you have the correct KUBECONFIG and context in scpoe, then run the following command:
# curl https://raw.githubusercontent.com/jradtke-suse/rancher-inventory/refs/heads/main/Scripts/gather-info.sh | bash -s -

# Manual Steps
# Validate/confirm current context is pointing to Rancher Manager
kubectl config get-contexts

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

exit 0
