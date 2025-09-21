# Node Feature Discovery
# My exploration of: https://github.com/kubernetes-sigs/node-feature-discovery

kubectl apply -k "https://github.com/kubernetes-sigs/node-feature-discovery/deployment/overlays/default?ref=v0.17.3"
while sleep 2; do echo; kubectl get pods -n node-feature-discovery | egrep ContainerCreating || break && { echo "Waiting for pods to start..."; } ; done
kubectl get no -o json | jq ".items[].metadata.labels"
