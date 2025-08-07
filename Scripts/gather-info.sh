#!/bin/bash

# Purpose: to gather host CPU information from clusters managed by Rancher

kubectl config get-contexts

OUTPUT=rancher-systems-summary-$(date +%F).out

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


