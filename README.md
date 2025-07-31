

# Objective

To align with the subscription model introduced in 2025, the goal is to get an accurate detailed overview of the compute resources dedicated to the Kubernetes environment managed by Rancher.  This information will ensure that the optimal subscription allocation is created to ensure cost-optimization for this coverage.

For bare metal/physical nodes: determine how many sockets/cores.
For virtual machines: vCPU count and role.
Identify the kubernetes role (control-plane vs worker) for each of the systems.
Additionally, the baseOS running on each node needs to be identified.

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

Example output:

```bash
geeko:~ jradtke$ kubectl apply -f https://raw.githubusercontent.com/rancherlabs/support-tools/master/collection/rancher/v2.x/systems-information-v2/deploy.yaml

pod/rancher-systems-summary-pod created
geeko:~ jradtke$
geeko:~ jradtke$ while [[ $(kubectl get pod rancher-systems-summary-pod -n cattle-system -o 'jsonpath={..status.phase}') != "Succeeded" ]]; do
>   echo "Waiting for rancher-systems-summary-pod to complete..."
>   sleep 5
> done
Waiting for rancher-systems-summary-pod to complete...
geeko:~ jradtke$ kubectl logs pod/rancher-systems-summary-pod -n cattle-system > rancher-systems-summary-$(date +%F).out
geeko:~ jradtke$ kubectl delete pod/rancher-systems-summary-pod -n cattle-system
pod "rancher-systems-summary-pod" deleted
geeko:~ jradtke$ cat rancher-systems-summary-$(date +%F).out
Rancher Systems Summary Report
==============================
Run on Thu Jul 31 12:15:44 UTC 2025

NAME                       READY   STATUS    RESTARTS        AGE
rancher-79b4455664-dd4qn   1/1     Running   2 (2d18h ago)   4d14h
Rancher version: v2.11.3
Rancher id: 57299729-c16b-4857-8a48-3a45f36b2b94

Cluster Id     Name             K8s Version      Provider    Created                Nodes
c-4kt65        3nuc-harvester   v1.32.4+rke2r1   harvester   2025-07-26T21:28:19Z   <none>
c-m-kx8wmvsd   k3s-stackstate   v1.32.6+k3s1     k3s         2025-07-31T02:52:31Z   <none>
c-m-szt2shxt   rke2-harv        v1.32.5+rke2r1   rke2        2025-07-26T21:32:11Z   <none>
local          local            v1.32.6+k3s1     k3s         2025-07-26T21:23:04Z   <none>

--------------------------------------------------------------------------------
Cluster: 3nuc-harvester (c-4kt65)
Node Id         Address               etcd   Control Plane   Worker   CPU   RAM          OS                     Container Runtime Version   Created
machine-br42p   10.10.12.103,nuc-03   true   true            false    12    65544024Ki   Harvester v1.5.1-rc2   containerd://2.0.4-k3s2     2025-07-26T21:30:26Z
machine-f4zxg   10.10.12.101,nuc-01   true   true            false    12    65560404Ki   Harvester v1.5.1-rc2   containerd://2.0.4-k3s2     2025-07-26T21:30:26Z
machine-hqtmv   10.10.12.102,nuc-02   true   true            false    12    65544016Ki   Harvester v1.5.1-rc2   containerd://2.0.4-k3s2     2025-07-26T21:30:26Z
Node count: 3

--------------------------------------------------------------------------------
Cluster: k3s-stackstate (c-m-kx8wmvsd)
Node Id         Address                                        etcd   Control Plane   Worker   CPU   RAM          OS                                    Container Runtime Version    Created
machine-hkmsb   10.10.15.72,k3s-stackstate-pool1-d9gtk-6r8jf   true   true            true     8     16378816Ki   SUSE Linux Enterprise Server 15 SP7   containerd://2.0.5-k3s1.32   2025-07-31T02:58:08Z
Node count: 1

--------------------------------------------------------------------------------
Cluster: rke2-harv (c-m-szt2shxt)
Node Id         Address                                   etcd   Control Plane   Worker   CPU   RAM         OS                                    Container Runtime Version   Created
machine-5r92g   10.10.15.55,rke2-harv-pool1-r2dbg-wnpvw   true   true            true     4     8136984Ki   SUSE Linux Enterprise Server 15 SP7   containerd://2.0.5-k3s1     2025-07-26T21:46:15Z
machine-hl4fq   10.10.15.53,rke2-harv-pool1-r2dbg-zbbw2   true   true            true     4     8136988Ki   SUSE Linux Enterprise Server 15 SP7   containerd://2.0.5-k3s1     2025-07-26T21:43:42Z
machine-r4vvz   10.10.15.54,rke2-harv-pool1-r2dbg-nzw2r   true   true            true     4     8136984Ki   SUSE Linux Enterprise Server 15 SP7   containerd://2.0.5-k3s1     2025-07-26T21:46:56Z
Node count: 3

--------------------------------------------------------------------------------
Cluster: local (local)
Node Id         Address                   etcd   Control Plane   Worker   CPU   RAM         OS                                    Container Runtime Version    Created
machine-mwx5g   10.10.12.122,rancher-02   true   true            false    2     7730528Ki   SUSE Linux Enterprise Server 15 SP6   containerd://2.0.5-k3s1.32   2025-07-26T21:23:21Z
machine-rnwmp   10.10.12.121,rancher-01   true   true            false    2     7730532Ki   SUSE Linux Enterprise Server 15 SP6   containerd://2.0.5-k3s1.32   2025-07-26T21:23:21Z
Node count: 2
--------------------------------------------------------------------------------
Total node count: 9
```
