# Kubernetes Learning Notes - 2026-03-02

## Tasks Accomplished

### Pod Configuration for UserService Container

- Created a Pod YAML file to run the UserService container
- Implemented proper namespace configuration (dev namespace)
- Created necessary RBAC components:
  - ServiceAccount
  - Role
  - RoleBinding YAML files

### Key Learning: Kubernetes Authorization vs Authentication

- **Kubernetes only handles authorization** - it manages what authenticated users can do
- **Authentication is handled by the Cloud Provider** (or external identity providers)
- Kubernetes does **not** maintain user databases or tables internally

### Configuration Management

- Created a ConfigMap (`user-service-config`) to manage environment variables
- Successfully referenced and used this ConfigMap in the backend-pod

### Testing and Connectivity

- Deployed the backend pod in dev namespace
- Used **port forwarding** to test the pod functionality through Postman
- Successfully connected to locally running services:
  - Database running on local machine
  - Redis running on local machine
- Used `host.docker.internal` to access local services from within the pod
- Verified connectivity by making test requests via port forwarding

### Database Migration Implementation

- Configured **Init Container** to run database migrations
- Ensured migrations run before the main container starts
- This ensures database schema is ready before application launches

### Image Pull Challenges and Resolution

- Initially faced issues pulling the UserService image
- Configured `imagePullPolicy: Never` in the pod specification
- Issue persisted because image wasn't loaded into minikube
- **Solution**: Pulled the image to minikube first, then successfully ran the container

### Debugging Skills

- Learned to debug container failures through:
  - Pod-level logging
  - Container-level logging
- Successfully identified Init Container failures by analyzing logs

## Technical Skills Acquired

### Commands and Operations

- **Port Forwarding**: Mastered port forwarding for local testing
- **Container Logging**: Practiced viewing and analyzing container logs
- **Debugging**: Learned systematic approach to container troubleshooting

### YAML Configuration Expertise

Gained proficiency in writing and understanding Kubernetes YAML structures for:

- **Pod** configurations
- **Role** definitions
- **RoleBinding** specifications
- **ServiceAccount** setup
- **Namespace** creation
- **ConfigMap** management

## Scenario-Based Learning

### Challenge Faced

Init Container failure when attempting to run migrations before the main container startup.

### Problem Resolution Steps

1. Identified the failure through pod-level logging
2. Traced the issue to image unavailability
3. Discovered that images must be explicitly loaded into minikube
4. Resolved by loading the image and verifying container startup

## Areas for Practice

- Container logging commands and interpretation
- Port forwarding for different scenarios
- Kubernetes YAML structure comprehension
- RBAC configuration best practices

## Key Takeaways

- Always verify image availability in the cluster before deployment
- Use Init Containers effectively for pre-main-container tasks
- Understand the separation of authentication (cloud) and authorization (Kubernetes)
- Leverage ConfigMaps for environment-specific configurations
- Master debugging through systematic log analysis
