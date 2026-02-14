it has two things Controle plane( Master node ) and worker node

kubectl apply -f pod.yaml
→ API Server stores pod spec
→ Scheduler assigns node
→ kubelet on that node creates the pod

kube-controller-manager
├─ Deployment Controller
├─ ReplicaSet Controller
├─ StatefulSet Controller
├─ DaemonSet Controller
├─ Job / CronJob Controller
├─ Node Controller
├─ Namespace Controller
├─ PV / PVC Controller
├─ HPA Controller

# ALL Bellow runes inside the kube-controller-manager (static Pod)

| Controller                              | Where it Runs | Why                      |
| --------------------------------------- | ------------- | ------------------------ |
| **Deployment Controller**               | Control Plane | Manages ReplicaSets      |
| **ReplicaSet Controller**               | Control Plane | Maintains Pod replicas   |
| **StatefulSet Controller**              | Control Plane | Manages stateful Pods    |
| **DaemonSet Controller**                | Control Plane | Ensures one Pod per node |
| **Job Controller**                      | Control Plane | Runs batch jobs          |
| **CronJob Controller**                  | Control Plane | Schedules jobs           |
| **Node Controller**                     | Control Plane | Monitors node health     |
| **Service Controller**                  | Control Plane | Creates ClusterIP / LB   |
| **Endpoint / EndpointSlice Controller** | Control Plane | Service → Pod IP mapping |
| **Namespace Controller**                | Control Plane | Namespace lifecycle      |
| **ServiceAccount Controller**           | Control Plane | Auth tokens              |
| **PV / PVC Controller**                 | Control Plane | Storage binding          |
| **HPA Controller**                      | Control Plane | Pod autoscaling          |
| **ResourceQuota Controller**            | Control Plane | Enforces quotas          |
| **LimitRange Controller**               | Control Plane | Default resource limits  |

---

## 🌐 Networking-Related Components

| Component              | Where it Runs | Notes             |
| ---------------------- | ------------- | ----------------- |
| **kube-proxy**         | Worker Nodes  | Runs as DaemonSet |
| **CNI Plugin**         | Worker Nodes  | Pod networking    |
| **Ingress Controller** | Worker Nodes  | Runs as Pods      |
| **CoreDNS**            | Worker Nodes  | Service discovery |

--- \***\*\*\*\*\*\*\*** \*\*\*\*

🔐 Security / Scheduling
| Component | Where it Runs | Notes |
| ------------------ | ------------- | ------------------- |
| **kube-scheduler** | Control Plane | Pod placement |
| **kube-apiserver** | Control Plane | Cluster entry point |
| **etcd** | Control Plane | Cluster state DB |

--- \***\*\*\*\***

## 🧩 Visual Summary

CONTROL PLANE
├─ kube-apiserver
├─ kube-scheduler
├─ kube-controller-manager
│ ├─ Deployment Controller
│ ├─ ReplicaSet Controller
│ ├─ Job Controller
│ ├─ Node Controller
│ └─ Service Controller
└─ etcd

WORKER NODE
├─ kubelet
├─ kube-proxy
├─ CNI Plugin
├─ Ingress Controller (Pod)
└─ Application Pods
