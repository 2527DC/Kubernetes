- Architecture Of the Kubernenties
- Controle plane & node , pod, Container
- controle Plane : etcd , scheduler, Api service , controle manager
- Worker nodes : kubelet , kube proxy , pod , container Ingress controller

- repleca Set
- Demon set ( where each node has default pod running )
- statefluu Set
- Deployment set
- Ingress Controller
- Services

  - Cluster Ip
  - Node Ip
  - Load Balancer
  - Headless Ip

- Methods : used ENV Based and DNS based

- NameSpace
- Selector
- Labels

# CNI ( Container Network Interface )

- I think i dont need to know about this how to implement need to know only when u and create a Kubernenties Provider where
  this CNI handles the internal network of the P < - > P & Np < -- > Np communication but as the begining i think insted of spending more time on it so learnt how is it and the plugines Calico , Cilium used

# Storage

- PersistentVolume (PV)
- PersistentVolumeClaim (PVC)
- CSI (Container Storage Interface )
- Dynamic provisioning
- StorageClass
