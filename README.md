## Laboratory Architecture

```mermaid
flowchart LR
    Host[VMware Workstation Host]

    subgraph VMnet1[VMnet1 - Host-only - 192.168.56.0/24]
        C1[compute-1]
        C2[compute-2]
        NN[netnode]
    end

    subgraph VMnet8[VMnet8 - NAT - 192.168.96.0/24]
        NAT1[NAT Connectivity]
    end

    Host --> VMnet1
    Host --> VMnet8

    C1 --> OVS1[Open vSwitch<br/>br-int / br-tun]
    C2 --> OVS2[Open vSwitch<br/>br-int / br-tun]

    OVS1 <-- VXLAN / VLAN --> OVS2

    NN --> DHCP[DHCP Services]
    NN --> Router[Routing / NAT]
    NN --> Floating[Floating IP]
    NN --> ISCSI[iSCSI / LVM Storage]

    C1 --> Docker1[Docker / Microservices]
    C1 --> K8s[Kubernetes Lab]
    C2 --> VMs2[KVM / Libvirt VMs]
    C1 --> VMs1[KVM / Libvirt VMs]

    C1 -. storage access .-> ISCSI
    C2 -. storage access .-> ISCSI
    C1 -. network services .-> DHCP
    C2 -. network services .-> DHCP
    C1 -. external connectivity .-> Floating
    C2 -. external connectivity .-> Floating

---

# 2) What this diagram shows

This explains your lab visually:

- **compute-1** and **compute-2** are the compute nodes
- both use **KVM/libvirt**
- both use **Open vSwitch**
- they communicate with each other using **VLAN/VXLAN**
- **netnode** provides:
  - **DHCP**
  - **routing/NAT**
  - **floating IP**
  - **iSCSI/LVM storage**
- `compute-1` also contains your **Docker / Kubernetes / microservice** work

---

# 3) A simpler version if you want less detail

If you want a cleaner and simpler visual, use this:

```markdown
## Simplified Architecture

```mermaid
flowchart TD
    A[VMware Workstation]

    A --> C1[compute-1]
    A --> C2[compute-2]
    A --> N[netnode]

    C1 --> C1R[KVM / Libvirt]
    C1 --> C1N[Open vSwitch]
    C1 --> C1D[Docker / Kubernetes]

    C2 --> C2R[KVM / Libvirt]
    C2 --> C2N[Open vSwitch]

    N --> ND[DHCP / NAT / Floating IP]
    N --> NS[iSCSI / LVM Storage]

    C1 <-- VLAN / VXLAN --> C2
    C1 -. uses network & storage .-> N
    C2 -. uses network & storage .-> N

---

# 4) Folder structure visual for README

You can also add this below the diagram:

```markdown
## Repository Structure

```text
ccn-cloud-computing-networking/
├── compute-1/
│   ├── virtualization/
│   ├── networking/
│   └── storage/
├── compute-2/
│   ├── virtualization/
│   └── networking/
├── netnode/
│   ├── virtualization/
│   ├── networking/
│   │   └── dhcp/
│   └── storage/
└── microservices/
    ├── sum/
    ├── sum.kubernetes/
    ├── chain/
    │   ├── add1/
    │   └── add2/
    ├── pingcontainers/
    └── name/


---

# 5) Nice badges for the top of README

At the top of the README, you can add badges like this:

```markdown
![Platform](https://img.shields.io/badge/platform-Ubuntu-orange)
![Virtualization](https://img.shields.io/badge/virtualization-KVM%20%7C%20libvirt-blue)
![Networking](https://img.shields.io/badge/networking-Open%20vSwitch%20%7C%20VXLAN-green)
![Containers](https://img.shields.io/badge/containers-Docker-blue)
![Orchestration](https://img.shields.io/badge/orchestration-Kubernetes-326ce5)
![Storage](https://img.shields.io/badge/storage-iSCSI%20%7C%20LVM-lightgrey)





# Cloud Computing and Networking — Hands-on Laboratory

**University:** University of Rome Tor Vergata  
**Course:** Cloud Computing and Networking (CCN)

## 1. Project Overview

This repository contains practical laboratory exercises developed during the Cloud Computing and Networking course.

The objective was to understand and implement the technologies behind cloud infrastructure, including server virtualization, software-defined networking, virtual network services, remote storage, containerization, and container orchestration.

Rather than relying entirely on cloud management platforms, the laboratory explores how the underlying infrastructure can be configured using Linux tools, scripts, and open-source technologies.

### Main Technologies

- **Virtualization:** VMware Workstation, KVM, QEMU, libvirt
- **Virtual Networking:** Linux Bridge, Open vSwitch, OpenFlow
- **Network Virtualization:** VLAN, VXLAN
- **Network Services:** Linux namespaces, DHCP, routing, NAT, floating IPs
- **Cloud Storage:** LVM, iSCSI, persistent and ephemeral storage
- **Containers:** Docker, Dockerfiles, Linux namespaces and cgroups
- **Orchestration:** Kubernetes, Pods, Services and deployment manifests
- **Programming and Automation:** Bash, Python, XML, YAML

## 2. Laboratory Architecture

The main infrastructure consists of three Ubuntu virtual machines deployed using VMware Workstation.

| Node | Role |
|---|---|
| compute-1 | Compute node for KVM/libvirt, Open vSwitch networking, virtual machines and container experiments |
| compute-2 | Second compute node for distributed virtualization and inter-host networking |
| netnode | Networking and storage node supporting DHCP, virtual routing, NAT, floating IP and iSCSI experiments |

### VMware Networking

The original VMware host environment uses two networks:

| VMware Network | Mode | Subnet |
|---|---|---|
| VMnet1 | Host-only | 192.168.56.0/24 |
| VMnet8 | NAT | 192.168.96.0/24 |

These are VMware-level networks. Additional virtual networks are configured inside the Ubuntu nodes.

### Virtual Network Architecture

The laboratory investigates extending isolated virtual networks across different compute nodes using:

- Local integration bridges (`br-int`)
- Tunnel bridges (`br-tun`)
- VLAN identifiers for local segmentation
- VXLAN tunnels for inter-host communication
- OpenFlow rules for packet forwarding and encapsulation

The course exercises include virtual networks associated with VLAN IDs 100 and 200 and their corresponding VXLAN identifiers.

The network services are implemented using Linux networking components to simulate functionality commonly managed by OpenStack Neutron.

**Note:** This is a hands-on infrastructure simulation, not a complete production OpenStack deployment.

## 3. Compute-1 — Virtualization and Networking

**Directory:** `compute-1/`

Compute-1 is the first compute node, used to investigate the creation and networking of virtual machines.

### Virtualization

- `vminstall-kvm.sh` — Script for creating or launching virtual machines using KVM/libvirt.
- `vminstall-ovs.sh` — Script associated with connecting virtual machines to Open vSwitch.
- `tc3-red.xml` — Libvirt configuration associated with the `tc3-red` VM.
- `br-int-net.xml` — Network configuration associated with the integration bridge.

### Virtual Networking

- `br-tun-reload-compute-1.sh` — Script associated with restoring the tunnel bridge, VXLAN networking and OpenFlow configurations.

### Storage

- `compute1-iscsi.sh` — Script associated with attaching remote iSCSI storage to the compute node.

## 4. Compute-2 — Distributed Virtualization

**Directory:** `compute-2/`

Compute-2 acts as an additional compute node for experiments involving virtual machines distributed across multiple hosts.

### Main Files

- `vminstall-kvm.sh` — KVM/libvirt virtual machine installation.
- `vminstall-ovs.sh` — Virtual machine networking through Open vSwitch.
- `tc2-red.xml` — Libvirt definition associated with `tc2-red`.
- `vnet1.xml` — Libvirt virtual network configuration.
- `br-int-net.xml` — Integration bridge network configuration.
- `br-tun-reload-compute-2.sh` — Tunnel networking and Open vSwitch configuration script.

### Learning Objectives

- Understand inter-host virtual networking.
- Connect virtual machines across separate compute nodes.
- Explore VLAN and VXLAN encapsulation.
- Configure virtual switching using Open vSwitch and OpenFlow.

## 5. Netnode — Networking and Remote Storage

**Directory:** `netnode/`

Netnode provides network services and remote block storage functionality to the laboratory environment.

### Network Services

| File | Purpose |
|---|---|
| `add-floating.sh` | Configures floating IP functionality with NAT |
| `br-tun-reload-netnode.sh` | Script associated with Open vSwitch tunnel networking |
| `neotronsim-reload.sh` | Reloads components of the simulated Neutron-style environment |
| `neotronsimr.sh` | Supporting simulated network-service configuration script |

### DHCP

Two DHCP configuration files are preserved:

- `networking/dhcp/vnet1-dhcp.conf`
- `networking/dhcp/vnet2-dhcp.conf`

These contain DHCP settings associated with the laboratory's virtual networks.

### iSCSI Storage

The `netnode-iscsi.sh` script is associated with configuring remote block storage.

The relevant laboratory concepts include:

- Physical volumes and volume groups
- Logical volumes
- iSCSI targets and initiators
- Persistent storage for virtual machines

Netnode was used as a storage provider to explore how compute nodes can access virtual disks over a network.

## 6. Docker and Python Microservices

**Directory:** `microservices/`

The laboratory includes Python-based applications packaged into Docker containers.

### Sum Microservice

**Directory:** `microservices/sum/`

Contains a Python sum application and a Dockerfile used to package it as a container image.

### Kubernetes Sum Application

**Directory:** `microservices/sum.kubernetes/`

Contains:

- `sum.py`
- `Dockerfile`
- `sum.yaml`

These files are associated with building and deploying the sum application in a Kubernetes environment.

### Chained Microservices

**Directory:** `microservices/chain/`

Contains two application components:

- `add1/`
- `add2/`

Each contains a Python application and Dockerfile.

The project demonstrates the concept of composing an application from multiple independently containerized services.

### Other Container Exercises

- `microservices/pingcontainers/` — Dockerfile associated with container networking experiments.
- `microservices/name/` — Python application preserved from the container exercises.

## 7. Kubernetes Concepts

The course investigated deploying and managing containerized applications using Kubernetes.

Topics include:

- Pods and shared networking
- Deployments and replication
- Kubernetes Services
- Container images
- YAML manifests
- Inter-service communication
- Ingress and externally exposed services

The repository currently preserves the Kubernetes-related source code and manifests identified in the original lab environment. Not every course topic necessarily has a separate implementation in this repository.

## 8. Repository Organization

| Directory | Contents |
|---|---|
| `compute-1/virtualization/` | KVM/libvirt scripts and XML configurations |
| `compute-1/networking/` | Open vSwitch and tunnel configuration scripts |
| `compute-1/storage/` | iSCSI compute-side scripts |
| `compute-2/virtualization/` | Compute-2 VM and network definitions |
| `compute-2/networking/` | Compute-2 tunnel configurations |
| `netnode/virtualization/` | Libvirt scripts and configurations |
| `netnode/networking/` | Virtual routing, NAT, VXLAN and DHCP |
| `netnode/storage/` | iSCSI storage script |
| `microservices/` | Docker, Python and Kubernetes experiments |

The subdirectories provide node-specific scripts and configurations. Additional README files can document their exact command sequences and dependencies.

## 9. Requirements and Reproduction

The laboratory was originally built using Ubuntu guest operating systems running inside VMware Workstation.

Reproducing the environment may require:

- A Linux host or virtual machine with suitable virtualization support
- Nested virtualization when running KVM inside VMware
- QEMU/KVM and libvirt
- Open vSwitch
- Linux networking utilities
- Docker
- Kubernetes tooling for container orchestration exercises
- Correctly configured VMware networking
- Suitable disk devices for the storage experiments

**Important:** The scripts contain environment-specific assumptions, such as interface names, IP addresses, network identifiers and storage-device paths.

They should be inspected and adapted before execution on another system. The repository is intended primarily for learning, documentation and demonstrating laboratory work, rather than as a one-command deployment solution.

## 10. Backups

The original VMware virtual machines are preserved separately in private OneDrive storage.

This GitHub repository stores selected source code, scripts, configuration files and project documentation.

Large VM disk images and VMware runtime files are intentionally excluded.

## 11. Documentation and Future Improvements

Planned improvements include:

- Documenting each script command by command
- Adding the complete laboratory architecture diagram
- Recording test commands and expected results
- Adding screenshots of verified experiments
- Documenting individual Docker and Kubernetes applications
- Improving repeatability of laboratory configurations

Some file descriptions remain preliminary until their contents and execution results are reviewed.

---

**Purpose:** Preserve practical knowledge from the CCN laboratory and demonstrate experience with cloud infrastructure, Linux networking, virtualization and container technologies.
