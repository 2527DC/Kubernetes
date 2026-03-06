kubectl get node -n namespace_name
kubectl get pod -n namespace_name

note :without the namespace it uses teh default namespace

kubectl delete pod/pod-name -n namespace_name

# Port-Forwarding

kubectl port-forward pod/pod-name localhost-port:containerport -n namespace_name
