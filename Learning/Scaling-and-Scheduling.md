# Scalling And Scheduling

# Horizontal Pod Scalling

# Vertical Pod Scalling

# Resource Quota And Limits

# Probes: This is used to get to Know about In which state Is our Application is that is Containers

- Liveness probe
- Startup probe
- Readiness probe

# Node Affinity : Node Affinity is a scheduling rule in Kubernetes that tells "This pod should run only on certain nodes."

- This is a update verison of Node selctor -> where u tell on which Node does this pod should run
- where u specify on which node the pod has to run means it will not run except that specified node of the given details

# Taints / Toleration

- **Taints** : This are Applied to the Node level
- **Toleration** : this are applied to the Pod level
- They work together to control which pods are allowed to run on which nodes.

- this will not make the pod to schedule on the specified nodes
