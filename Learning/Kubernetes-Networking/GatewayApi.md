# GATEWAYAPI.md

## Understanding Kubernetes Gateway API: A Complete Guide

A comprehensive reference covering the architecture, resources, responsibilities, and operational patterns of the Kubernetes Gateway API, including how it solves Ingress limitations and integrates with AWS VPC Lattice.

---

## Table of Contents

1. [Introduction: The Problem Gateway API Solves](#1-introduction-the-problem-gateway-api-solves)
2. [The Three Core Resources](#2-the-three-core-resources)
   - [GatewayClass](#21-gatewayclass-cluster-scope)
   - [Gateway](#22-gateway-namespace-scope)
   - [HTTPRoute](#23-httproute-namespace-scope)
3. [Resource Dependencies and Relationships](#3-resource-dependencies-and-relationships)
4. [Responsibility Split: Gateway vs HTTPRoute](#4-responsibility-split-gateway-vs-httproute)
5. [Multi-Controller and Multi-Gateway Scenarios](#5-multi-controller-and-multi-gateway-scenarios)
6. [AWS VPC Lattice Integration](#6-aws-vpc-lattice-integration)
7. [How Gateway API Solves Ingress Limitations](#7-how-gateway-api-solves-ingress-limitations)
8. [Summary and Key Takeaways](#8-summary-and-key-takeaways)

---

## 1. Introduction: The Problem Gateway API Solves

### 1.1 Limitations of Traditional Ingress Controllers

Traditional Kubernetes Ingress had several critical drawbacks that made it difficult to manage at scale:

| Problem                      | Impact                                                                                                                |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| **No Role Separation**       | Application developers needed cluster-level permissions just to expose their applications                             |
| **Annotation Overload**      | Advanced features like canary deployments, URL rewrites, and header matching required controller-specific annotations |
| **No Multi-Tenancy Support** | No built-in mechanism to prevent teams from conflicting with each other on shared load balancers                      |
| **Limited Standardization**  | Behavior varied wildly between NGINX, Traefik, AWS ALB, and other implementations                                     |
| **Weak Security Boundaries** | No way to restrict which namespaces could attach routes to a Gateway                                                  |

### 1.2 How Gateway API Solves These Problems

The Gateway API introduces a **role-based resource model** with clear ownership boundaries:

| Solution                       | Description                                                                                          |
| ------------------------------ | ---------------------------------------------------------------------------------------------------- |
| **Platform Team Ownership**    | Infrastructure resources (`GatewayClass`, `Gateway`) are managed by platform teams                   |
| **Developer Self-Service**     | Application logic (`HTTPRoute`) is managed by developers in their own namespaces                     |
| **Built-in Standards**         | Canary deployments, header matching, and traffic splitting are part of the API spec, not annotations |
| **Explicit Security Controls** | Cross-namespace access requires explicit allow-lists and `ReferenceGrant` resources                  |
| **Controller Agnostic**        | Standardized API works across all conformant controllers (NGINX, Envoy, AWS, etc.)                   |

---

## 2. The Three Core Resources

### 2.1 GatewayClass (Cluster Scope)

| Attribute        | Description                                                                       |
| ---------------- | --------------------------------------------------------------------------------- |
| **Scope**        | Cluster-wide                                                                      |
| **Who Creates**  | Platform Team / Infrastructure Provider / Cloud Provider                          |
| **What It Does** | Defines the type of Gateway Controller (NGINX, Envoy, AWS VPC Lattice)            |
| **How It Helps** | Provides top-level governance; ensures all Gateways use approved controller types |

**Key Concepts:**

- A `GatewayClass` maps to **one specific controller implementation**
- Multiple `GatewayClass` resources can exist in a cluster, each pointing to different controllers or different configurations of the same controller
- The `controllerName` field uniquely identifies which controller should handle this class

**Example Use Cases:**

| GatewayClass      | Purpose                                                      |
| ----------------- | ------------------------------------------------------------ |
| `internal-nginx`  | For internal services requiring specific NGINX configuration |
| `public-envoy`    | For public-facing services using Envoy proxy                 |
| `aws-vpc-lattice` | For AWS-managed service networking (no in-cluster proxy)     |

### 2.2 Gateway (Namespace Scope)

| Attribute        | Description                                                                                          |
| ---------------- | ---------------------------------------------------------------------------------------------------- |
| **Scope**        | Namespace                                                                                            |
| **Who Creates**  | Cluster Operator / Platform Team                                                                     |
| **What It Does** | Requests proxy infrastructure and defines security boundaries                                        |
| **How It Helps** | Acts as a gatekeeper; specifies which namespaces can attach routes and what SSL/firewall rules apply |

**What the Gateway Resource Contains:**

- **Reference to GatewayClass**: Determines which controller manages this Gateway
- **Listeners**: Define ports, protocols, and SSL certificates
- **Allowed Routes**: Explicitly list which namespaces can attach HTTPRoutes
- **Address Configuration**: Optional specification of IP addresses or hostnames

**What the Gateway Creates (Depends on Implementation):**

| Implementation           | What Gets Created                                                          |
| ------------------------ | -------------------------------------------------------------------------- |
| **Envoy Gateway**        | Envoy proxy pods inside the cluster, typically with a LoadBalancer service |
| **NGINX Gateway Fabric** | NGINX proxy pods inside the cluster                                        |
| **AWS VPC Lattice**      | AWS-managed service network (no pods run in your cluster)                  |

### 2.3 HTTPRoute (Namespace Scope)

| Attribute        | Description                                                                                |
| ---------------- | ------------------------------------------------------------------------------------------ |
| **Scope**        | Namespace                                                                                  |
| **Who Creates**  | Application Developer                                                                      |
| **What It Does** | Defines application-level routing logic                                                    |
| **How It Helps** | Enables self-service; developers can expose applications without cluster admin permissions |

**What the HTTPRoute Contains:**

- **Parent References**: Links to the Gateway(s) this route should attach to
- **Rules**: Define matches (paths, headers, methods) and backend destinations
- **Filters**: URL rewrites, header modifications, request mirroring
- **Traffic Splitting**: Weight-based distribution across multiple backends

**Important Constraints:**

- An HTTPRoute can only route to services in its own namespace by default
- Cross-namespace service references require a `ReferenceGrant` resource
- The Gateway's `allowedRoutes` determines if the HTTPRoute's namespace is permitted to attach

---

## 3. Resource Dependencies and Relationships

### 3.1 The Dependency Chain

The Gateway API resources form a hierarchical dependency chain:

```
┌─────────────────────────────────────────────────────────────────┐
│                     GatewayClass (Cluster)                       │
│  • Maps to a specific controller (e.g., NGINX, Envoy, AWS)     │
│  • Typically created once per controller type                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Gateway (Namespace)                       │
│  • References a GatewayClass                                    │
│  • Defines listeners (ports, SSL, protocols)                    │
│  • Specifies allowed namespaces for route attachment            │
│  • May create actual proxy infrastructure (LoadBalancer, etc.) │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       HTTPRoute (Namespace)                      │
│  • References parent Gateway(s) via parentRefs                 │
│  • Defines routing rules (path matching, header rules)          │
│  • Specifies backend services and weights                        │
│  • Applies filters (rewrites, header mods)                      │
└─────────────────────────────────────────────────────────────────┘
```

**Dependency Order:**

1. `GatewayClass` must exist before a `Gateway` can reference it
2. `Gateway` must exist and accept routes before an `HTTPRoute` can attach
3. Backend services referenced by `HTTPRoute` must exist (or use cross-namespace `ReferenceGrant`)

### 3.2 The Handshake Mechanism

The "handshake" between Gateway and HTTPRoute is what enables secure multi-tenancy:

1. **Platform Team** creates a GatewayClass (defines available controller types)
2. **Platform Team** creates a Gateway in a namespace:
   - Specifies `gatewayClassName`
   - Defines listeners (ports, SSL)
   - Sets `allowedRoutes.namespaces` (e.g., `from: Selector` with specific namespace labels)
3. **Developer** in an allowed namespace creates an HTTPRoute:
   - Uses `parentRefs` to attach to the Gateway
   - Defines routing rules for their application
4. **Controller** validates:
   - Is the HTTPRoute's namespace in the Gateway's allowed list?
   - Does the HTTPRoute correctly reference the Gateway?
   - If yes → route is accepted and traffic flows
   - If no → route is ignored with a status condition

### 3.3 Visualizing the Security Boundary

```
┌──────────────────────────────────────────────────────────────────┐
│                    Gateway (infra namespace)                     │
│  allowedRoutes: namespaces: [team-a, team-b]                    │
│  listeners: port 443, SSL: my-cert                              │
└──────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  HTTPRoute   │    │  HTTPRoute   │    │  HTTPRoute   │
│   (team-a)   │    │   (team-b)   │    │   (team-c)   │
│ ✅ Allowed   │    │ ✅ Allowed   │    │ ❌ Ignored   │
└──────────────┘    └──────────────┘    └──────────────┘
```

---

## 4. Responsibility Split: Gateway vs HTTPRoute

This separation of responsibilities is fundamental to the Gateway API design.

### 4.1 Responsibility Table

| Responsibility                       | Gateway Resource | HTTPRoute Resource |
| ------------------------------------ | :--------------: | :----------------: |
| SSL/TLS Certificates                 |        ✅        |         ❌         |
| Firewall / Allowed IP Ranges         |        ✅        |         ❌         |
| Ports and Protocols                  |        ✅        |         ❌         |
| Load Balancer Settings               |        ✅        |         ❌         |
| Path Matching (`/api`, `/login`)     |        ❌        |         ✅         |
| Header Matching                      |        ❌        |         ✅         |
| Query Parameter Matching             |        ❌        |         ✅         |
| HTTP Method Matching                 |        ❌        |         ✅         |
| Traffic Splitting (Canary)           |        ❌        |         ✅         |
| URL Rewrites                         |        ❌        |         ✅         |
| Request/Response Header Modification |        ❌        |         ✅         |
| Request Mirroring                    |        ❌        |         ✅         |

### 4.2 Why This Split Matters

| Role                      | Owns      | Responsibility                                                                                  |
| ------------------------- | --------- | ----------------------------------------------------------------------------------------------- |
| **Platform Team**         | Gateway   | Infrastructure provisioning, security boundaries, SSL certificates, load balancer configuration |
| **Application Developer** | HTTPRoute | Application routing, canary deployments, A/B testing, request transformation                    |

This separation enables:

- **Self-service** for developers without cluster admin permissions
- **Security** enforced at the infrastructure level
- **Autonomy** for teams to manage their own traffic rules
- **Governance** through centralized Gateway management

---

## 5. Multi-Controller and Multi-Gateway Scenarios

### 5.1 Can I Have Multiple Instances of the Same Controller?

**Yes.** You can have multiple Gateway resources, each creating separate proxy infrastructure, all managed by the same controller.

```
Cluster
├── NGINX Gateway Fabric Controller (one set of pods)
├── GatewayClass: "internal-nginx" → same controller
├── GatewayClass: "public-nginx" → same controller
├── Gateway: "internal-gateway" (uses internal-nginx class)
│   └── Creates its own NGINX proxy pods
└── Gateway: "public-gateway" (uses public-nginx class)
    └── Creates its own NGINX proxy pods
```

### 5.2 Configuration Options

| Scenario                               | Implementation                                                                                          |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| **Same controller, different configs** | Multiple GatewayClasses referencing same controller; Gateways choose different GatewayClasses           |
| **Different controllers**              | Multiple GatewayClasses (one for NGINX, one for Envoy); Gateways choose which to use                    |
| **Isolated team gateways**             | Each team creates their own Gateway in their namespace (creates separate proxy pods and load balancers) |

### 5.3 One Gateway for All vs Separate per Project

| Approach                  | Description                                                        | Pros                                                   | Cons                                                            |
| ------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------ | --------------------------------------------------------------- |
| **Single Shared Gateway** | One Gateway resource for all teams, all HTTPRoutes attach to it    | Cost efficient (one load balancer), simpler management | Looser security boundaries, potential route conflicts           |
| **Gateway per Team**      | Each team creates their own Gateway in their namespace             | Strong isolation, teams can't affect each other        | Higher cost (multiple load balancers), more management overhead |
| **Hybrid Approach**       | Shared Gateway for public apps, team Gateways for internal/staging | Best of both worlds, appropriate isolation levels      | Requires careful planning and governance                        |

---

## 6. AWS VPC Lattice Integration

### 6.1 What is AWS VPC Lattice?

AWS VPC Lattice is a **fully managed service** by AWS that handles service-to-service networking across VPCs and accounts. It is **not** a traditional proxy running in your cluster—the traffic handling infrastructure is managed by AWS outside your cluster.

### 6.2 How It Works with Gateway API

| Component                      | Role                                                                                        |
| ------------------------------ | ------------------------------------------------------------------------------------------- |
| **AWS Gateway API Controller** | Runs in your cluster and translates Gateway API resources to VPC Lattice configurations     |
| **GatewayClass**               | `amazon-vpc-lattice` tells the controller to use VPC Lattice instead of an in-cluster proxy |
| **Gateway**                    | Creates or updates a VPC Lattice service network                                            |
| **HTTPRoute**                  | Creates or updates a VPC Lattice service with auto-generated domain names                   |

### 6.3 Comparison: In-Cluster Proxy vs AWS VPC Lattice

| Aspect                    | NGINX/Envoy Gateway                       | AWS VPC Lattice                           |
| ------------------------- | ----------------------------------------- | ----------------------------------------- |
| **Where Proxy Runs**      | Inside cluster (pods)                     | AWS managed (outside cluster)             |
| **Load Balancer**         | Created by controller in your AWS account | Managed by AWS                            |
| **SSL/TLS Management**    | In-cluster certificates or cert-manager   | AWS Certificate Manager (ACM) integration |
| **Cross-VPC Routing**     | Complex (requires VPC peering)            | Built-in                                  |
| **Cross-Account Routing** | Not natively supported                    | Built-in                                  |
| **Cost Model**            | Control plane + compute resources         | Usage-based (requests processed)          |
| **DNS**                   | External IP or CNAME                      | Auto-generated VPC Lattice domains        |
| **Observability**         | Prometheus, Grafana, logs                 | AWS CloudWatch, VPC Lattice console       |

### 6.4 When to Use AWS VPC Lattice

| Scenario                             | Recommendation                                                       |
| ------------------------------------ | -------------------------------------------------------------------- |
| **Multi-account architecture**       | Excellent choice; VPC Lattice natively handles cross-account traffic |
| **Multi-VPC environments**           | Ideal; eliminates need for VPC peering or Transit Gateway            |
| **Teams wanting reduced ops burden** | Great; no proxy pods to manage, scale, or patch                      |
| **AWS-native organizations**         | Natural fit; integrates with ACM, IAM, CloudWatch                    |
| **Service-to-service communication** | Primary use case; designed for microservice networking               |
| **Single-cluster, single-VPC**       | In-cluster proxy may be simpler and more cost-effective              |

---

## 7. How Gateway API Solves Ingress Limitations

| Ingress Limitation                                               | Gateway API Solution                                                                         |
| ---------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Developers needed cluster-level access to expose applications    | Developers only create HTTPRoutes in their namespaces; no cluster-level permissions required |
| Advanced features required controller-specific annotations       | Built-in fields for header matching, traffic splitting, URL rewrites, and request modifiers  |
| No separation of concerns between platform and application teams | Platform Team owns Gateway (infrastructure); Developers own HTTPRoute (application logic)    |
| Controller-specific quirks and non-portable configurations       | Standardized API across all conformant controllers; portable configurations                  |
| No cross-namespace security controls                             | `allowedRoutes` in Gateway explicitly controls which namespaces can attach routes            |
| Conflicts on shared load balancers                               | Each Gateway can be isolated per team; multiple Gateways can coexist                         |
| No standard for canary deployments                               | Built-in `weight` field in HTTPRoute backendRefs for native traffic splitting                |
| No standard for A/B testing                                      | Built-in header and query parameter matching for routing based on request attributes         |
| Complex request transformations required custom logic            | Built-in filters for URL rewrite, header modification, and request mirroring                 |

---

## 8. Summary and Key Takeaways

### 8.1 Core Concepts

| Concept                            | Summary                                                                                                                             |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **Gateway API is a Specification** | It defines resources and behavior, not the actual proxy. You still need a controller (NGINX, Envoy, AWS) to implement it.           |
| **Three-Tier Architecture**        | `GatewayClass` (cluster-level controller type) → `Gateway` (namespace-level infrastructure) → `HTTPRoute` (namespace-level routing) |
| **Security is Built-in**           | Gateways explicitly define which namespaces can attach routes, enabling true multi-tenancy.                                         |
| **Role Separation**                | Platform teams own infrastructure; application developers own routing logic.                                                        |
| **Multi-Controller Support**       | Multiple GatewayClasses can coexist, and multiple Gateways can use them, enabling flexible isolation strategies.                    |

### 8.2 Decision Guide

| Question                                             | Consideration                                                                                       |
| ---------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| **What is your organizational structure?**           | One platform team with many app teams → Gateway per team or hybrid approach                         |
| **Do you need multi-cloud portability?**             | Use controller-agnostic Gateway API with Envoy or NGINX for consistent behavior across clouds       |
| **Are you heavily invested in AWS?**                 | Consider AWS VPC Lattice for reduced operational overhead and cross-account capabilities            |
| **What is your tolerance for operational overhead?** | In-cluster proxies require management; VPC Lattice is fully managed but may have higher usage costs |
| **Do you need advanced traffic management?**         | All conformant controllers support standard features; Envoy offers the most advanced capabilities   |

### 8.3 Final Thoughts

The Gateway API represents a significant evolution in Kubernetes networking. By standardizing the interface while allowing diverse implementations, it provides:

- **Portability** across cloud providers and controller implementations
- **Security** through explicit, namespace-aware access controls
- **Flexibility** to choose between in-cluster proxies and managed services
- **Scalability** to support hundreds of teams and thousands of services

For organizations running Kubernetes at scale, migrating from Ingress to Gateway API is not just an upgrade—it's a fundamental shift toward secure, self-service application networking.

---

_This document is based on Gateway API v1.2+ and reflects best practices as of March 2026._

_For implementation details and code examples, refer to the official Gateway API documentation and your chosen controller's documentation._
