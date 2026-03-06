1 -> I have a Fiel of secrets or config map and if we want to change those How is it handles

- using Cloud secrets
- Manual changes
- Automatic changes

2Q -> when i use the init container for the side workd what if the init container fails i think
it will go inio loop how to handle those things

# What is the Difference detween the replica and the scalling what is the use of replica how does it heps explain with example

- Answere : replica in k8s is the no of pod running initially after the deployment but the scalling is handled based on the metric like usage of memory and cpus and req limit
- The replica is used for the availability example
  **See when u dont use the Replica:**
  -> If the node crash where ur pod is running then untill the another node creation by scaller the aplciation is not availabel if u have two replica which are in 2 nodes if one node gets down then the other pod that is running on the other node will still remains available

doubt -> If i have more than one pod of replicas how handles spliting the trafic will both be handling the trafic or only one of them will recive the req and how does this happens like one of the pod get crash and how the trafic are redirected or how the req reaches the another pod of the replica
