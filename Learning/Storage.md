# Kubernetes Storage

Kubernetes provides various storage solutions to meet different application requirements. Storage in Kubernetes is broadly categorized into **Ephemeral** and **Persistent** storage.

---

## 1. Ephemeral Storage

Ephemeral storage is temporary and does not persist data beyond the lifecycle of a pod. When a pod is deleted, the data stored in ephemeral volumes is lost.

### 1.1 emptyDir

An `emptyDir` volume is created when a Pod is assigned to a Node. It starts empty and exists for the duration of the Pod's lifecycle.

- **Use case**: Temporary scratch space, caching, or sharing data between containers in a multi-container pod.
- **Storage location**: By default, stored on the node's disk. Can be configured to use memory (tmpfs).
- **Lifetime**: Tied to the pod lifecycle - deleted when pod is removed.

```yaml
volumes:
- name: cache-volume
  emptyDir: {}
```

### 1.2 ConfigMap

A `ConfigMap` is used to store non-sensitive configuration data in key-value pairs. It can be mounted as volumes or environment variables.

- **Use case**: Store configuration files, command-line arguments, or any configurable data.
- **Persistence**: Not meant for persistent data - configurations are fetched from the ConfigMap at runtime.
- **Mounting**: Can be mounted as files or exposed as environment variables.

```yaml
volumes:
- name: config-volume
  configMap:
    name: my-config-map
```

### 1.3 Secrets

`Secrets` are similar to ConfigMaps but intended to store small amounts of sensitive data like passwords, OAuth tokens, and SSH keys.

- **Use case**: Store sensitive information securely.
- **Encoding**: Data is base64 encoded (not encrypted by default - requires additional configuration for encryption at rest).
- **Mounting**: Can be mounted as files or exposed as environment variables.
- **Security**: Should use external secrets management solutions (e.g., Vault, AWS Secrets Manager) for production.

```yaml
volumes:
- name: secret-volume
  secret:
    secretName: my-secret
```

---

## 2. Persistent Storage

Persistent storage persists data beyond the lifecycle of a pod. It is ideal for databases, file stores, and applications requiring durable data.

### 2.1 hostPath

A `hostPath` volume mounts a file or directory from the host node's filesystem into the Pod.

- **Use case**: Testing, development, or when pods need access to node-specific resources.
- **Persistence**: Data persists on the host node, but tied to a specific node.
- **Warning**: Not suitable for production multi-node clusters as pods may be scheduled on different nodes.

```yaml
volumes:
- name: host-path-volume
  hostPath:
    path: /data
    type: Directory
```

### 2.2 Cloud Storage

Cloud storage solutions provide network-based persistent storage that can be accessed from any node in the cluster.

- **Examples**: 
  - **AWS**: EBS (Elastic Block Store), EFS (Elastic File System)
  - **GCP**: Persistent Disk
  - **Azure**: Azure Disk, Azure Files
- **Use case**: Production workloads requiring durable, scalable storage accessible from any node.
- **Benefits**: Managed by cloud provider, highly available, automatic replication.

---

## 3. PersistentVolume (PV) and PersistentVolumeClaim (PVC)

### 3.1 PersistentVolume (PV)

A **PersistentVolume** is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes.

- **Location**: Inside the cluster
- **Lifecycle**: Independent of any individual Pod
- **Types**: Can be backed by various storage types (local, NFS, cloud storage, etc.)
- **Provisioned by**: Administrator or dynamically via StorageClass

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  storageClassName: standard
  hostPath:
    path: /mnt/data
```

### 3.2 PersistentVolumeClaim (PVC)

A **PersistentVolumeClaim** is a request for storage by a user. It is like a pod - pods consume node resources (CPU, RAM), while PVCs consume PV resources (storage).

- **Requesting storage**: Requests storage from **external sources** (like cloud storage) or internal storage
- **Location**: Request is made from within the cluster, but the actual storage can be external
- **Binding**: When a PVC is created, Kubernetes binds it to an available PV that matches the requirements
- **Access modes**: ReadWriteOnce (RWO), ReadOnlyMany (ROX), ReadWriteMany (RWX)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard
```

### Key Relationship

- **PVC** = Request for storage (asks for space)
- **PV** = Actual storage resource (provides space)
- The PVC requests storage from external sources or cluster-internal storage, and Kubernetes binds the claim to an appropriate PV.

---

## 4. Storage Classes

A **StorageClass** provides a way to define different "classes" of storage. It allows dynamic provisioning of PersistentVolumes based on the requirements.

### Why Use StorageClasses?

1. **Dynamic Provisioning**: Automatically creates PVs when a PVC requests storage, eliminating the need for manual PV creation.
2. ** abstraction**: Provides a layer of abstraction between users and underlying storage infrastructure.
3. **Multiple Storage Types**: Allows defining different storage types (fast SSD, slow HDD, cloud storage, etc.) for different workloads.
4. **Cloud Provider Integration**: Simplifies integration with cloud storage providers.

### How It Works

1. User creates a PVC requesting storage with a specific StorageClass
2. The StorageClass's provisioner creates the appropriate storage (e.g., cloud disk)
3. A PV is automatically created and bound to the PVC

### Example

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-storage
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  replication-type: regional-pd
```

### Common Provisioners

| Provisioner | Description |
|-------------|-------------|
| `kubernetes.io/aws-ebs` | AWS Elastic Block Store |
| `kubernetes.io/gce-pd` | Google Persistent Disk |
| `kubernetes.io/azure-disk` | Azure Disk |
| `kubernetes.io/nfs` | NFS (Network File System) |
| `ceph.com/ceph` | Ceph RBD |
| `no-provisioner` | Static provisioning (manual PV creation) |

### Use Case Example

```yaml
# PVC requesting storage with StorageClass
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fast-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: fast-storage
```

When this PVC is created, the `fast-storage` StorageClass will automatically provision a new PersistentVolume (e.g., an SSD-backed volume on GCE) and bind it to the claim.

---

## Summary

| Type | Description | Persistence |
|------|-------------|-------------|
| emptyDir | Temporary storage for pods | No |
| ConfigMap | Non-sensitive configuration | No |
| Secrets | Sensitive configuration | No |
| hostPath | Node filesystem storage | Yes (node-specific) |
| Cloud Storage | Network-based storage | Yes |
| PV | Cluster storage resource | Yes |
| PVC | Storage request | Yes |
| StorageClass | Dynamic provisioning | Yes |
