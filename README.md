

# Objective

To align with the subscription model introduced in 2025, the goal is to get an accurate detailed overview of the compute resources dedicated to the Kubernetes environment managed by Rancher.  This information will ensure that the optimal subscription allocation is created to ensure cost-optimization for this coverage.

For bare metal/physical nodes: determine how many sockets/cores.
For virtual machines: vCPU count and role.
Identify the kubernetes role (control-plane vs worker) for each of the systems.
Additionally, the baseOS running on each node needs to be identified.

## Notes

* Inspection of Bare Metal results is recommended.  Intel Hyper-Threading and AMT Simultaneous Multithreading (SMT) have become ubiquitous, and the core density is not easily determined.  Therefore, it is recommended to review the actual CPU model and determine how many cores are possible, followed by confirmation that all cores are available (system configuration may not have the functionality enabled)
 

## Data Gathering Process
### Rancher 2.x Systems Summary v2

The script runs as a pod in the Rancher 2.x cluster and collects information about the systems in the cluster. The script collects the following information:

- Rancher server version and installation UUID.
- Details of all clusters managed by Rancher, including:
  - Cluster ID and name
  - Kubernetes version
  - Provider type
  - Creation timestamp
  - Nodes associated with each cluster
- For each cluster, detailed information about each node, including:
  - Node ID and address
  - Role within the cluster
  - CPU and RAM capacity
  - Operating system and Docker version
  - Creation timestamp
- Total count of nodes across all clusters.

### How to use

Run the following command to deploy the script as a pod in the Rancher local cluster:

```bash
# Deploy the pod in the cluster
kubectl apply -f https://raw.githubusercontent.com/rancherlabs/support-tools/master/collection/rancher/v2.x/systems-information-v2/deploy.yaml

# Wait for the pod to reach Succeeded status
while [[ $(kubectl get pod rancher-systems-summary-pod -n cattle-system -o 'jsonpath={..status.phase}') != "Succeeded" ]]; do
  echo "Waiting for rancher-systems-summary-pod to complete..."
  sleep 5
done

# Grab the logs from the pod
kubectl logs pod/rancher-systems-summary-pod -n cattle-system > rancher-systems-summary-$(date +%F).out

# Clean up the pod
kubectl delete pod/rancher-systems-summary-pod -n cattle-system
```

NOTE: It might take a few minutes for the pod to collect the information and display it in the logs. The script will delete the pod after displaying the information.

## Example output:

[Summary Output Examples](./Output)

