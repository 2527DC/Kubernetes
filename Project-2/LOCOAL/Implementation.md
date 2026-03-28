# Migration Strategy

## Why I Used a Job Instead of Init Container for Migrations

I chose to use a Kubernetes Job to run migrations instead of an Init Container because when the application is scaled, the scaled pods would also attempt to run migrations, which is unnecessary and could cause issues.

- Replicas are used to make the application highly available and scalable.

## Resource Management

I implemented two important resource management features:

### ResourceQuota
Defines the total amount of resources that can be used by all pods in a namespace.

### LimitRange
Sets the minimum and maximum resource limits for individual pods or containers within a namespace.

**Use Case:** If there is a namespace with multiple pods that need the same resources, and all containers in that namespace require identical resource allocations, you can create a separate LimitRange YAML and apply it to that namespace.

## Question

If there are no resource limits defined in a namespace but there is a Deployment using the same namespace, what happens? Will the pod be stuck in a creation loop? Or will the Deployment itself fail to create?

How can this be debugged? Is there a tool to help diagnose issues like this?

## Problems Encountered

### Problem 1: Service Port Conflict
Using the same target port in both the ERP and ETS services caused "site can't be reached" errors when listing applications via port forwarding.

### Problem 2: 502 Bad Gateway Error
After deploying the ERP project, I encountered a 502 Bad Gateway error. Initially, I couldn't determine the cause because running the container locally (outside the cluster) worked fine.

**Debugging Steps:**
1. I accessed the pod level and ran debugging commands inside the container.
2. Commands used:
   ```bash
   php artisan tinker --execute="echo config('app.env');"
   php artisan tinker --execute="echo config('database.connections.mysql.host');"
   ```
3. The AI suggested the issue was due to resource limits—the server was not able to run with the allocated resources.

**Solution:**
To check if pod resources are insufficient, use:
```bash
kubectl top pod -n erp-dev
```
