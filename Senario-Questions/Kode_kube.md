# Kubernetes Task – Create a Pod

## Scenario

The Nautilus DevOps team is diving into Kubernetes for application management.  
One team member has been assigned the following task.

## Task

Using the `kubectl` utility available on `jump_host` (already configured to work with the Kubernetes cluster), complete the following:

1. Create a Pod named **pod-nginx**.
2. Use the image **nginx:latest** (explicitly specify the `latest` tag).
3. Set a label:
   - `app: nginx_app`
4. Name the container:
   - `nginx-container`

---

## Instructions

### Step 1: Create a YAML file

Create a file named `pod-nginx.yaml`:

```bash
vi pod-nginx.yaml
```
