Here is your **scenario-based Kubernetes practice file**.
You can copy this into a file named:

```
kubernetes-kind-practice.md
```

---

# Kubernetes Hands-On Practice (Using kind)

This document contains **real-world scenario-based tasks** to help you deeply understand:

- Architecture
- Control Plane Components
- Pods & Containers
- ReplicaSet / Deployment / DaemonSet / StatefulSet
- Services
- Ingress
- Namespace / Labels / Selectors
- Storage (PV / PVC)
- CNI basics
- DNS & ENV based communication

Use **kind (Kubernetes in Docker)** locally.

---

# 🚀 Setup

### Task 0 – Setup Local Cluster

1. Install `kind`
2. Create a cluster:

   ```bash
   kind create cluster --name dev-cluster
   ```

3. Verify:

   ```bash
   kubectl get nodes
   ```

👉 Question:

- Which node is acting as Control Plane?
- Can you see etcd running? Try:

  ```bash
  kubectl get pods -n kube-system
  ```

---

# 🧠 Scenario 1: Application Deployment (Deployment + Service)

## Scenario:

You are deploying a Node.js app called `myapp` that must run 3 replicas.

### Tasks:

1. Create a **Deployment** with:

   - Image: nginx
   - Replicas: 3
   - Label: app=myapp

2. Verify:

   ```bash
   kubectl get pods -o wide
   ```

3. Scale to 5 replicas.

4. Update image version.

👉 Questions:

- What component ensures desired replicas? (Deployment or ReplicaSet?)
- What happens if you delete one pod manually?

---

# 🌐 Scenario 2: Service Types (ClusterIP, NodePort, LoadBalancer, Headless)

## Scenario:

Your app needs to be accessed internally and externally.

### Task A – ClusterIP

1. Expose deployment using ClusterIP.
2. Create another test pod:

   ```bash
   kubectl run test --image=busybox -it --rm -- sh
   ```

3. Curl service DNS:

   ```
   curl myapp-service
   ```

👉 Question:

- How does DNS resolve this name?

---

### Task B – NodePort

1. Change service type to NodePort.
2. Access it from your browser.

👉 Question:

- How does traffic flow?
  Browser → NodeIP:NodePort → kube-proxy → Pod

---

### Task C – Headless Service

1. Create Headless Service (`clusterIP: None`)
2. Observe DNS entries:

   ```bash
   nslookup myapp-service
   ```

👉 Question:

- Why are multiple IPs returned?

---

# 🏗 Scenario 3: Stateful Application (StatefulSet)

## Scenario:

You are deploying a database cluster.

### Tasks:

1. Create a StatefulSet with:

   - 3 replicas
   - Headless service
   - nginx image (for learning)

2. Check pod names:

   ```
   mydb-0
   mydb-1
   mydb-2
   ```

👉 Questions:

- Why are names ordered?
- What happens if pod `mydb-0` is deleted?

---

# 🖥 Scenario 4: DaemonSet

## Scenario:

You need a logging agent running on every node.

### Tasks:

1. Create a DaemonSet using nginx.
2. Add one more worker node (if using multi-node kind cluster).
3. Observe pods.

👉 Question:

- Why is one pod running per node?

---

# 📦 Scenario 5: Persistent Storage (PV & PVC)

## Scenario:

Your application must store data permanently.

### Tasks:

1. Create a PersistentVolume (hostPath).
2. Create a PersistentVolumeClaim.
3. Mount it in a Pod.
4. Write data inside container.
5. Delete pod.
6. Recreate pod.

👉 Question:

- Is the data still there?
- What binds PV to PVC?

---

# 🔀 Scenario 6: Ingress Controller

## Scenario:

You have two apps:

- app1
- app2

You want:

- `/app1` → app1 service
- `/app2` → app2 service

### Tasks:

1. Install Nginx Ingress Controller in kind.
2. Create two deployments.
3. Create ingress resource.
4. Test using:

   ```
   curl localhost/app1
   ```

👉 Question:

- How does traffic flow?
  Browser → Ingress → Service → Pod

---

# 🏷 Scenario 7: Labels & Selectors

## Scenario:

You have frontend and backend pods.

### Tasks:

1. Create 2 frontend pods (label: tier=frontend)
2. Create 2 backend pods (label: tier=backend)
3. Create a service selecting only frontend.

👉 Question:

- What happens if labels don’t match?
- Does service break?

---

# 🧩 Scenario 8: Namespace Isolation

## Scenario:

You have:

- dev environment
- prod environment

### Tasks:

1. Create namespaces:

   ```bash
   kubectl create ns dev
   kubectl create ns prod
   ```

2. Deploy same app in both.

3. Try accessing across namespaces.

👉 Question:

- Can service in dev access prod by default?
- What DNS format is used?

  ```
  service-name.namespace.svc.cluster.local
  ```

---

# 🌐 Scenario 9: CNI Understanding

## Scenario:

Two pods communicate directly.

### Tasks:

1. Create 2 pods.
2. Get IP of first pod.
3. From second pod, ping first pod.

👉 Questions:

- How are pods able to talk without NAT?
- What provides this networking? (CNI plugin)

Research:

- Calico
- Cilium

Do NOT implement plugin.
Just understand:

- Pod-to-Pod
- Node-to-Node routing

---

# 🔄 Scenario 10: ENV vs DNS Communication

## Scenario:

Backend needs DB connection.

### Task A – ENV Based

1. Add environment variable in deployment:

   ```yaml
   env:
     - name: DB_HOST
       value: mysql-service
   ```

### Task B – DNS Based

Inside pod:

```
ping mysql-service
```

👉 Question:

- Which is better?
- Why DNS is preferred?

---

# 🔥 Final Challenge (Mini Project)

## Build This:

- Namespace: production
- Frontend Deployment (3 replicas)
- Backend Deployment (2 replicas)
- MySQL StatefulSet
- PVC attached
- ClusterIP services
- Ingress routing
- Labels properly defined

Then simulate:

- Pod crash
- Node failure (delete node in kind)
- Scale deployment
- Delete PVC and observe behavior

---

# 🎯 Architecture Understanding Questions

1. What happens when you run:

   ```
   kubectl apply -f app.yaml
   ```

   Flow:
   kubectl → API Server → etcd → Scheduler → Kubelet → Container runtime

2. What does kube-proxy do?

3. Where does etcd store data?

4. What ensures desired state?

5. What happens if control plane goes down?

---

# 🏁 Goal

After completing all tasks, you should clearly understand:

- Kubernetes Architecture
- Control Plane components
- Networking (Service + CNI)
- Storage
- Workloads
- Traffic flow
- Internal DNS
- Scaling & Self-healing

---

If you want, I can next give you:

- ✅ Real DevOps Interview Scenario Questions
- ✅ Debugging-based Kubernetes problems
- ✅ Production-level architecture challenge
- ✅ YAML-only challenge (no kubectl create shortcuts)

Tell me what level you want next 🚀
