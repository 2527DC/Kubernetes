# Container Network Interface (CNI) in Kubernetes

## Overview

CNI (Container Network Interface) is a specification and a set of libraries for configuring network interfaces in Linux containers. In Kubernetes, CNI is the plugin mechanism that handles network connectivity for Pods.

## CNI Specification

### Purpose
- Provides a vendor-neutral interface for network plugin development
- Defines how container runtimes (like containerd, cri-o) communicate with network plugins
- Standardizes container network configuration

### Specification Requirements
CNI plugins must implement:

1. **ADD**: Add a container to the network
2. **DEL**: Remove a container from the network
3. **CHECK**: Check if container network is correctly configured
4. **VERSION**: Report plugin version

### Configuration Format
```json
{
  "cniVersion": "0.3.1",
  "name": "mynetwork",
  "type": "bridge",
  "bridge": "cni0",
  "isGateway": true,
  "ipam": {
    "type": "host-local",
    "subnet": "10.88.0.0/16"
  }
}
```

## CNI Plugins

### Plugin Types

#### 1. Main Plugins
| Plugin | Description |
|--------|-------------|
| `bridge` | Creates a bridge and attaches containers |
| `host-device` | Moves existing device to container namespace |
| `macvlan` | Creates MAC-based virtual interface |
| `ipvlan` | Creates IPv4/IPv6 virtual interface |
| `loopback` | Sets loopback interface up |

#### 2. IPAM Plugins (IP Address Management)
| Plugin | Description |
|--------|-------------|
| `dhcp` |获取IP from DHCP server |
| `host-local` | Local IP address allocation |
| `static` | Static IP address assignment |

#### 3. Meta Plugins
| Plugin | Description |
|--------|-------------|
| `tuning` | Adjusts sysctl parameters |
| `portmap` | Port mapping/forwarding |
| `bandwidth` | Traffic shaping |
| `flannel` | Overlay networking |
| `calico` | CNI plugin for Calico |
| `cilium-cni` | CNI plugin for Cilium |
| `weave` | Weave Net CNI plugin |

### Common Plugin Combinations

**Flannel with host-local:**
```json
{
  "cniVersion": "0.3.1",
  "name": "flannel",
  "type": "flannel",
  "delegate": {
    "type": "bridge",
    "ipam": {
      "type": "host-local",
      "subnet": "10.244.0.0/16"
    }
  }
}
```

**Calico:**
```json
{
  "cniVersion": "0.3.1",
  "name": "calico",
  "type": "calico",
  "ipam": {
    "type": "calico-ipam"
  }
}
```

## CNI in Kubernetes

### How It Works

1. **Kubelet** detects a Pod needs network
2. **Kubelet** calls CNI plugin with container info
3. **CNI Plugin**:
   - Creates network interface in Pod namespace
   - Allocates IP address (via IPAM)
   - Configures routes
4. **Result** returned to Kubelet

### Delegated System

The delegated system in CNI refers to:

1. **Plugin Chaining**: Plugins can delegate to other plugins
2. **IPAM Delegation**: Main plugins delegate IP address management to IPAM plugins
3. **Meta-plugins**: Delegate to other plugins via `delegate` config

Example delegation flow:
```
Kubelet → Bridge Plugin → Host-local IPAM → Returns IP
```

### CNI Configuration in Kubernetes

**Location:** `/etc/cni/net.d/`

**Plugin execution order:** Files are sorted alphabetically, first plugin with valid config wins

```
/etc/cni/net.d/
├── 10-calico.conflist
├── 10-flannel.conflist
└── 99-loopback.conf
```

### Network Plugins ConfigMap

Kubelet flag: `--network-plugin=cni`

## Troubleshooting CNI Issues

### Common Scenarios and Solutions

#### 1. Pods Stuck in `ContainerCreating` State

**Symptoms:**
- Pod not getting IP address
- `kubectl get pods` shows `ContainerCreating`

**Troubleshooting:**
```bash
# Check CNI plugin logs
journalctl -u kubelet -n 50

# Check pod network status
kubectl describe pod <pod-name>

# Verify CNI config exists
ls -la /etc/cni/net.d/

# Check if CNI binary exists
ls /opt/cni/bin/
```

**Causes:**
- CNI plugin binary missing
- Misconfigured CNI config
- IP address exhaustion

---

#### 2. Pods Can't Reach Internet

**Symptoms:**
- Pods can communicate internally but not external

**Troubleshooting:**
```bash
# Check iptables rules
iptables -L -n -v

# Check pod network namespace
ip netns list

# Verify NAT rules
iptables -t nat -L -n -v

# Check node routing
ip route
```

**Causes:**
- CNI plugin not configuring NAT
- iptables rules missing/corrupted
- Host firewall blocking

---

#### 3. Pods Can't Communicate Across Nodes

**Symptoms:**
- Pods on same node communicate fine
- Pods on different nodes cannot communicate

**Troubleshooting:**
```bash
# Check CNI plugin type
cat /etc/cni/net.d/00-default.conflist

# Verify VXLAN/overlay settings
ip link show
ip -d link show

# Check cluster CIDR
kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}'

# Test connectivity
nc -zv <remote-pod-ip> <port>
```

**Causes:**
- Overlay network misconfigured
- Firewall blocking VXLAN ports (4789/8472)
- Pod CIDR overlap

---

#### 4. CNI Plugin Crashes

**Symptoms:**
- New pods fail to start
- Plugin process not running

**Troubleshooting:**
```bash
# Check plugin process
ps aux | grep <cni-plugin>

# Check logs
journalctl -u <plugin-service> -n 100

# Verify plugin binary
file /opt/cni/bin/<plugin>

# Check config syntax
cat /etc/cni/net.d/*.conflist | python3 -m json.tool
```

---

#### 5. IP Address Conflicts

**Symptoms:**
- Pods getting same IP
- Intermittent connectivity

**Troubleshooting:**
```bash
# Check IPAM allocation
kubectl get pods -o wide

# Check node pod CIDRs
kubectl get nodes -o jsonpath='{.items[*].status.addresses}'

# Verify IPAM config
cat /etc/cni/net.d/*ipam*
```

**Causes:**
- Misconfigured IPAM (overlapping subnets)
- Node podCIDR not set
- IPAM cache corruption

---

#### 6. DNS Resolution Fails in Pods

**Symptoms:**
- Pods can't resolve service names

**Troubleshooting:**
```bash
# Check DNS config in pod
kubectl exec <pod> -- cat /etc/resolv.conf

# Check CoreDNS status
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Verify cluster domain
kubectl describe pod <pod> | grep -i dns
```

---

### Useful Diagnostic Commands

```bash
# List all network interfaces on node
ip link show

# Show CNI plugins available
ls -la /opt/cni/bin/

# View CNI configuration
cat /etc/cni/net.d/10-flannel.conflist

# Check kubelet network plugin settings
ps aux | grep kubelet | grep cni

# Get pod network namespace
kubectl get pod <name> -o jsonpath='{.metadata.annotations.kubernetes\.io/createdBy}'

# Test from node to pod
nc -n -z <pod-ip> <port>

# Check VXLAN traffic
tcpdump -i <vxlan-interface> -n
```

### Debug Mode

Enable CNI debugging:
```bash
# For Flannel
curl -X POST http://127.0.0.1:8500/v1/kv/flannel/config -d '{"Value": {"Network": "10.244.0.0/16", "Backend": {"Type": "vxlan"}}}'

# For Calico
calicoctl get ippool -o wide
calicoctl node status
```

## Best Practices

1. **Always use CNI version 0.3.1 or higher** for feature compatibility
2. **Validate CNI config** before applying: `cat config.json | python3 -m json.tool`
3. **Keep backup of working CNI config**
4. **Use specific plugin versions** - avoid mixing plugin versions
5. **Monitor CNI plugin logs** in production
6. **Ensure firewall rules** allow CNI traffic (VXLAN, IP-in-IP)
7. **Configure pod CIDR properly** - avoid overlaps
8. **Use IPAM with conflict detection**
