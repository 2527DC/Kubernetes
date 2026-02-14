Kubernenties architecture
cluster , node , pod --->(differences)

# Namespaces

- The Namespace in the kubereneties refers as the logical (virtual) boundary and the scope of this namespace is pod level
  which helps to secrigation and making isolated environament for the resources

Deployements
Replicaset
Rolebackupdates
Labels and Selectors
replicaset vs Statefulset vs Deployement

Statefull set is the set which maintains the state of the pods
Deamon Set
Jobs , cron jobs
Storage:
Storage Clasess
persistent storage
persistent claim storage

# Side Car

- It is the extra container in the same pod where the aplication stays where it helps in different situations
  ex -> the application generates a log in its aplication file and if u want it as and keeping it as standard levaraging way then
  u make this side car container to read it and share them to some monitoring system
