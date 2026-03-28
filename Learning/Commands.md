# Kubernetes Commands Reference

A quick reference guide for essential Kubernetes commands with links to real-world scenarios where they are used.

---

## Table of Contents

1. [Cluster Management](#1-cluster-management)
2. [Pod Management](#2-pod-management)
3. [Deployment Management](#3-deployment-management)
4. [Service Management](#4-service-management)
5. [Namespace Management](#5-namespace-management)
6. [Scaling & Updates](#6-scaling--updates)
7. [Debugging & Inspection](#7-debugging--inspection)
8. [Storage](#8-storage)
9. [Networking](#9-networking)
10. [Labels & Selectors](#10-labels--selectors)

---

## 1. Cluster Management

### Get Cluster Information

```bash
kubectl cluster-info
```

**Scenario:** Verify that kubectl is properly configured and can communicate with the cluster.

> _"Verify:"_ [Core-hands-On.md - Task 0 - Setup Local Cluster](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=3.%20Verify%3A,58)

### Get Nodes

```bash
kubectl get nodes
```

**Scenario:** Check which nodes are available in the cluster and their status.

> _"Which node is acting as Control Plane?"_ [Core-hands-On.md - Task 0 - Setup Local Cluster](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=Which%20node%20is%20acting%20as%20Control%20Plane)

### Get System Pods

```bash
kubectl get pods -n kube-system
```

**Scenario:** View pods running in the kube-system namespace to check core components.

> _"Can you see etcd running? Try:"_ [Core-hands-On.md - Task 0 - Setup Local Cluster](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=Can%20you%20see%20etcd%20running)

### Create a Cluster (kind)

```bash
kind create cluster --name dev-cluster
```

**Scenario:** Create a local Kubernetes cluster using kind for development.

> _"Create a cluster:"_ [Core-hands-On.md - Task 0 - Setup Local Cluster](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=2.%20Create%20a%20cluster)

---

## 2. Pod Management

### Create a Pod

```bash
kubectl run pod-nginx --image=nginx:latest --labels=app=nginx_app
```

**Scenario:** Create a simple nginx pod with specific labels.

> _"Create a Pod named pod-nginx with image nginx:latest"_ [Kode_kube.md - Task](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Kode_kube.md#:~:text=1.%20Create%20a%20Pod%20named)

### Get Pods

```bash
kubectl get pods
```

**Scenario:** List all pods in the current namespace.

> _"Verify:"_ [Core-hands-On.md - Scenario 1](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=2.%20Verify,58)

### Get Pods with Wide Output

```bash
kubectl get pods -o wide
```

**Scenario:** View pods with additional details like node assignment.

> _"kubectl get pods -o wide"_ [Core-hands-On.md - Scenario 1](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=2.%20Verify,58)

### Get Pods in All Namespaces

```bash
kubectl get pods --all-namespaces
```

**Scenario:** View all pods across all namespaces in the cluster.

### Describe a Pod

```bash
kubectl describe pod <pod-name>
```

**Scenario:** Get detailed information about a specific pod including events and conditions.

### Delete a Pod

```bash
kubectl delete pod <pod-name>
```

**Scenario:** Remove a specific pod from the cluster.

> _"Delete pod and observe behavior"_ [Core-hands-On.md - Final Challenge](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=Delete%20PVC%20and%20observe%20behavior)

### Execute Command in Pod

```bash
kubectl exec -it <pod-name> -- /bin/sh
```

**Scenario:** Open an interactive shell inside a running pod for debugging.

### Print Pod Logs

```bash
kubectl logs <pod-name>
```

**Scenario:** View the logs of a specific pod.

### Watch Pod Status

```bash
kubectl get pods -w
```

**Scenario:** Continuously monitor pod status changes in real-time.

---

## 3. Deployment Management

### Create a Deployment

```bash
kubectl create deployment <name> --image=<image>
```

**Scenario:** Create a deployment from a container image.

### Apply YAML Configuration

```bash
kubectl apply -f <file.yaml>
```

**Scenario:** Create or update resources from a YAML manifest file.

> _"kubectl apply -f app.yaml"_ [Core-hands-On.md - Architecture Understanding](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=kubectl%20apply%20-f%20app.yaml)

### Get Deployments

```bash
kubectl get deployments
```

**Scenario:** List all deployments in the current namespace.

### Describe Deployment

```bash
kubectl describe deployment <deployment-name>
```

**Scenario:** View detailed information about a deployment including its status.

### Delete Deployment

```bash
kubectl delete deployment <deployment-name>
```

**Scenario:** Remove a deployment and all its managed pods.

### Scale Deployment

```bash
kubectl scale deployment <name> --replicas=<count>
```

**Scenario:** Change the number of replicas for a deployment.

> _"Scale to 5 replicas."_ [Core-hands-On.md - Scenario 1](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=3.%20Scale%20to%205%20replicas)

### Set Deployment Image

```bash
kubectl set image deployment/<name> <container>=<image>
```

**Scenario:** Update the container image for a deployment.

> _"Update image version."_ [Core-hands-On.md - Scenario 1](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=4.%20Update%20image%20version)

### Rollout Restart

```bash
kubectl rollout restart deployment/<name>
```

**Scenario:** Trigger a rolling restart of a deployment without changing any configuration.

> _"The rollout completed successfully"_ [Port-forwording.md](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Port-forwording.md#:~:text=Then%20I%20updated%20the%20container%20image%20and%20performed%20a%20rollout)

### Check Rollout Status

```bash
kubectl rollout status deployment/<name>
```

**Scenario:** Monitor the progress of a deployment rollout.

### Undo Rollout

```bash
kubectl rollout undo deployment/<name>
```

**Scenario:** Rollback to the previous version of a deployment.

### View Rollout History

```bash
kubectl rollout history deployment/<name>
```

**Scenario:** View the revision history of a deployment.

---

## 4. Service Management

### Expose Deployment as Service

```bash
kubectl expose deployment <name> --type=<type> --port=<port>
```

**Scenario:** Create a service to expose a deployment.

> _"Expose deployment using ClusterIP."_ [Core-hands-On.md - Scenario 2](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=Task%20A%20%E2%80%93%20ClusterIP,1.%20Expose%20deployment%20using%20ClusterIP)

### Get Services

```bash
kubectl get services
```

**Scenario:** List all services in the current namespace.

### Describe Service

```bash
kubectl describe service <service-name>
```

**Scenario:** View detailed information about a service including endpoints.

### Delete Service

```bash
kubectl delete service <service-name>
```

**Scenario:** Remove a service from the cluster.

### Service Types Reference

| Type         | Command Flag          | Use Case                              |
| ------------ | --------------------- | ------------------------------------- |
| ClusterIP    | `--type=ClusterIP`    | Internal cluster communication        |
| NodePort     | `--type=NodePort`     | External access via node ports        |
| LoadBalancer | `--type=LoadBalancer` | Cloud provider external load balancer |
| Headless     | `--clusterIP=None`    | StatefulSet direct pod discovery      |

> _"Access it from your browser."_ [Core-hands-On.md - Scenario 2 - Task B](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=Task%20B%20%E2%80%93%20NodePort,1.%20Change%20service%20type%20to%20NodePort)

---

## 5. Namespace Management

### Create Namespace

```bash
kubectl create namespace <name>
```

**Scenario:** Create a new namespace for environment isolation.

> _"Create namespaces:"_ [Core-hands-On.md - Scenario 8](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=1.%20Create%20namespaces)

### Get Namespaces

```bash
kubectl get namespaces
```

**Scenario:** List all namespaces in the cluster.

### Get Resources in Namespace

```bash
kubectl get <resource> -n <namespace>
```

**Scenario:** View resources in a specific namespace.

### Set Default Namespace

```bash
kubectl config set-context --current --namespace=<name>
```

**Scenario:** Change the default namespace for all subsequent kubectl commands.

### Delete Namespace

```bash
kubectl delete namespace <name>
```

**Scenario:** Remove a namespace and all resources within it.

---

## 6. Scaling & Updates

### Auto-Scale Deployment

```bash
kubectl autoscale deployment <name> --min=<min> --max=<max> --cpu-percent=<percent>
```

**Scenario:** Set up horizontal pod autoscaling based on CPU utilization.

### Rolling Update

```bash
kubectl rolling-update <name> -f <new-deployment.yaml>
```

**Scenario:** Perform a rolling update of a deployment (legacy method).

### Label a Deployment

```bash
kubectl label deployment <name> tier=<value>
```

**Scenario:** Add or update labels on a deployment.

> _"Create 2 frontend pods (label: tier=frontend)"_ [Core-hands-On.md - Scenario 7](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=1.%20Create%202%20frontend%20pods)

### Annotate a Resource

```bash
kubectl annotate <resource-type> <name> <annotation>
```

**Scenario:** Add metadata annotations to any Kubernetes resource.

---

## 7. Debugging & Inspection

### Port Forward to Pod

```bash
kubectl port-forward pod/<pod-name> <local-port>:<pod-port>
```

**Scenario:** Access a pod's ports from your local machine for debugging.

> _"kubectl port-forward svc/sample-data-service 8080:80 -n dev"_ [Port-forwording.md](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Port-forwording.md#:~:text=kubectl%20port-forward%20svc)

### Port Forward to Service

```bash
kubectl port-forward svc/<service-name> <local-port>:<service-port>
```

**Scenario:** Forward traffic to a service for local testing.

> _"Access the application again from the browser"_ [Port-forwording.md](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Port-forwording.md#:~:text=However,%20when%20I%20tried%20to%20access%20the%20application%20again%20from%20the%20browser)

### Copy Files to/from Pod

```bash
kubectl cp <pod-name>:/path/to/file ./local-file
```

**Scenario:** Copy files from a pod to your local machine for inspection.

### Check Resource Usage

```bash
kubectl top pods
kubectl top nodes
```

**Scenario:** View CPU and memory usage for pods or nodes.

### Get Events

```bash
kubectl get events
kubectl get events --sort-by='.lastTimestamp'
```

**Scenario:** View cluster events to troubleshoot issues.

### Dry Run

```bash
kubectl apply -f <file.yaml> --dry-run=client
```

**Scenario:** Validate a YAML file without actually applying it.

### Explain Resource

```bash
kubectl explain <resource-type>
```

**Scenario:** Get documentation about a specific Kubernetes resource type.

---

## 8. Storage

### Create PersistentVolume

```bash
kubectl create -f pv.yaml
```

**Scenario:** Create a PersistentVolume for persistent storage.

> _"Create a PersistentVolume (hostPath)"_ [Core-hands-On.md - Scenario 5](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=1.%20Create%20a%20PersistentVolume)

### Get PersistentVolumes

```bash
kubectl get pv
```

**Scenario:** List all PersistentVolumes in the cluster.

### Get PersistentVolumeClaims

```bash
kubectl get pvc
```

**Scenario:** List all PersistentVolumeClaims in the current namespace.

### Describe PV/PVC

```bash
kubectl describe pv <name>
kubectl describe pvc <name>
```

**Scenario:** View detailed information about storage resources.

### Delete PV/PVC

```bash
kubectl delete pvc <name>
```

**Scenario:** Remove a PVC and observe behavior when deleted.

> _"Delete PVC and observe behavior"_ [Core-hands-On.md - Final Challenge](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=Delete%20PVC%20and%20observe%20behavior)

---

## 9. Networking

### Get Endpoints

```bash
kubectl get endpoints
```

**Scenario:** View the IP addresses of pods backing a service.

### Check DNS Resolution

```bash
kubectl exec -it <pod> -- nslookup <service-name>
```

**Scenario:** Verify DNS resolution for a service.

> _"Observe DNS entries"_ [Core-hands-On.md - Scenario 2 - Task C](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=2.%20Observe%20DNS%20entries)

### Test Service Connectivity

```bash
kubectl run test --image=busybox -it --rm -- sh
```

**Scenario:** Create a temporary pod to test service connectivity.

> _"Create another test pod:"_ [Core-hands-On.md - Scenario 2 - Task A](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=2.%20Create%20another%20test%20pod)

### Curl from Pod

```bash
kubectl exec -it <pod> -- curl <service-name>
```

**Scenario:** Test HTTP connectivity to a service from within a pod.

> _"Curl service DNS:"_ [Core-hands-On.md - Scenario 2 - Task A](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=3.%20Curl%20service%20DNS)

### Get Ingress Resources

```bash
kubectl get ingress
```

**Scenario:** List all ingress resources in the namespace.

> _"Create ingress resource"_ [Core-hands-On.md - Scenario 6](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=3.%20Create%20ingress%20resource)

### Create Ingress

```bash
kubectl create ingress <name> --rule="path=service:port"
```

**Scenario:** Create an ingress resource for HTTP routing.

> _"curl localhost/app1"_ [Core-hands-On.md - Scenario 6](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=4.%20Test%20using,curl%20localhost/app1)

---

## 10. Labels & Selectors

### Get Pods with Label Selector

```bash
kubectl get pods -l app=myapp
```

**Scenario:** Filter pods based on label selectors.

### Get Pods with Multiple Selectors

```bash
kubectl get pods -l 'tier in (frontend,backend)'
```

**Scenario:** Filter pods using set-based selectors.

### Label a Pod

```bash
kubectl label pod <name> tier=frontend
```

**Scenario:** Add a label to an existing pod.

### Remove Label

```bash
kubectl label pod <name> tier-
```

**Scenario:** Remove a specific label from a pod.

### Create Service with Selector

```bash
kubectl expose deployment <name> --selector=tier=frontend
```

**Scenario:** Create a service that selects pods with specific labels.

> _"Create a service selecting only frontend"_ [Core-hands-On.md - Scenario 7](#file:///Users/admin/Desktop/Learning/Kubernetes/Senario-Questions/Core-hands-On.md#:~:text=3.%20Create%20a%20service%20selecting%20only%20frontend)

---

## Quick Reference: Common Workflows

### Deploy an Application

```bash
kubectl create deployment myapp --image=nginx
kubectl expose deployment myapp --type=LoadBalancer --port=80
```

### Scale an Application

```bash
kubectl scale deployment myapp --replicas=5
```

### Update an Application

```bash
kubectl set image deployment/myapp nginx=nginx:1.21
kubectl rollout status deployment/myapp
```

### Debug an Application

```bash
kubectl get pods -l app=myapp
kubectl logs <pod-name>
kubectl describe pod <pod-name>
kubectl exec -it <pod-name> -- /bin/sh
```

### Clean Up

```bash
kubectl delete deployment myapp
kubectl delete service myapp
```

---

## File Reference Links

| Scenario File                                                 | Description                             |
| ------------------------------------------------------------- | --------------------------------------- |
| [Core-hands-On.md](../Senario-Questions/Core-hands-On.md)     | Hands-on practice with kind cluster     |
| [Port-forwording.md](../Senario-Questions/Port-forwording.md) | Port forwarding and debugging scenarios |
| [Kode_kube.md](../Senario-Questions/Kode_kube.md)             | Pod creation tasks                      |

---

_This document serves as a quick reference for Kubernetes commands. For detailed explanations and hands-on practice, refer to the scenario files linked above._
