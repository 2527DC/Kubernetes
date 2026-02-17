# Services in the kubernentis

- What role does the services play in the Kuberneties .In kuberneties the services is used to handel the pod
  availability and make soure it doent not brake

# How does it Helps

- When the pod dies and recreates the ip changes and the access to the application breaks and this service helps
  to maintain the IP for the pods

# Types of Services

1 -> Cluster Ip
2 -> Node ip
3 -> Headless Ip
4 -> LoadBalancer
5 -> External names

# Method of Services (Service Discovery)

DNS-Based Service Discovery
--> pods are accessed and recognized by the service name which are specified

ENV Based
->The Ip of the pods are coded in the env file and it is resolved at the time of pod creation the ip are resloved and
maped to the pod

Headless Service Discovery
--> In This menthod u make it by using none in the place of ip ClusterIp (type )
--> Insted of returning the name space for the pod comunnication that is singe cluster IP
insted it returns all the pod Ip

This cant be used in the LoadBalancer as it tends to break connection
It cant be used for the load balancer because
ex: think u have 1 db of main and another 2 of replicas if some one make a insert operation
the data must get inserted into the primary databse not the replicas where the replicated
db can die
