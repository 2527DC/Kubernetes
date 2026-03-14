# Kubernetes Scenario Questions

## Scenario 1: Handling Secrets and ConfigMap Changes

**Question:** I have a set of secrets or ConfigMaps, and if we want to change those, how is it handled?

**Options:**
- Using Cloud secrets
- Manual changes
- Automatic changes

---

## Scenario 2: Init Container Failure Handling

**Question:** When I use an init container for side work, what if the init container fails? I think it will go into a loop. How do we handle those scenarios?

---

## Scenario 3: Replicas vs Scaling

**Question:** What is the difference between replicas and scaling? What is the use of replicas, and how does it help? Explain with an example.

**Answer:**

Replicas in Kubernetes refer to the number of pod instances running initially after the deployment. Scaling, on the other hand, is handled based on metrics like memory usage, CPU usage, and request limits.

**The use of replicas for availability:**

Consider this scenario - when you do not use replicas:
- If the node crashes where your pod is running, the application will not be available until another node is created by the autoscaler.

When you have two replicas running on two different nodes:
- If one node goes down, the pod running on the other node will still remain available, ensuring high availability.

---

## Scenario 4: Traffic Handling with Multiple Replicas

**Question:** If I have more than one pod of replicas, how is traffic splitting handled? Will both be handling the traffic, or will only one of them receive the requests? How does this happen? If one of the pods crashes, how is traffic redirected, and how do requests reach another pod in the replica set?
