Kubernenties architecture
cluster , node , pod --->(differences)

# Namespaces

- The Namespace in the kubereneties refers as the logical (virtual) boundary and the scope of this namespace is pod level
  which helps to secrigation and making isolated environament for the resources

# Core Concepts

- Labels and Selectors , Architecture

# Workloads

- Deployements ,Replicaset ,Rolebackupdates ,replicaset vs Statefulset vs Deployement

# Netwoeking

- cluster networking , Service , Ingress , Network Police , GateWay Api

# Storage

- PV , PVC , Storage Clasess, config manps , secrets

# Scaling and Scheduling

- HPA , VPA, Node Affinity, Taints /tolarance , Resource Quotas , Limits , Probes

# Cluster Administration

- RBAC , cluster updates , Custom Resource Definetion ( CRD's)

# Monitoring and Logging

- tools , Metric server , logging

# Security

- Pod Security Standards (PSS ) , Image Scanning , Network Policies , Secrets Encryption

# Cloud Native Kuberenties

- Manage Services ( EKS , AKS , GKE) , Cluster Auto Scaler , Spot / Preemtible Node

# Debugging And trouble Shooting

- kubectl Debugging ,Logs, Resource Usage Analystic

# Advance Feature

- Operators , Helm, Service Mesh , kubernenties Api

# Side Car

- It is the extra container in the same pod where the aplication stays where it helps in different situations
  ex -> the application generates a log in its aplication file and if u want it as and keeping it as standard levaraging way then
  u make this side car container to read it and share them to some monitoring system

# In-Place Pod Vertical Scaling -> in new Version of Kuberneties
