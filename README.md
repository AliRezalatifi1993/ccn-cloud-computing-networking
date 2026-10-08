# ccn-cloud-computing-networking

Hands-on cloud computing and networking labs: KVM, libvirt, Open vSwitch, VLAN/VXLAN, Linux networking, storage, Docker, and Kubernetes.

# Cloud Computing and Networking — Laboratory Projects

**University:** University of Rome Tor Vergata  
**Course:** Cloud Computing and Networking (CCN)

## Overview

This repository documents hands-on laboratory exercises involving virtualization, software-defined networking, cloud storage, containerization, and Kubernetes.

The lab environment consists of three Ubuntu virtual machines running under VMware Workstation:

- **compute-1:** Compute node for KVM/libvirt, virtual networking, and container experiments.
- **compute-2:** Additional compute node for distributed virtualization and networking.
- **netnode:** Network services and remote storage node.

## Compute-1

### Virtualization

- `vminstall-kvm.sh` — Installs or launches virtual machines using KVM/libvirt.
- `vminstall-ovs.sh` — Intended for launching VMs attached to Open vSwitch networking.
- `tc3-red.xml` — Libvirt configuration associated with a virtual machine named tc3-red.
- `br-int-net.xml` — Network configuration associated with the integration bridge.

### Virtual Networking

- `br-tun-reload-compute-1.sh` — Restores or configures tunnel-related networking on compute-1, potentially including Open vSwitch and VXLAN/OpenFlow rules.

### Storage

- `compute1-iscsi.sh` — Script associated with connecting compute-1 to remote iSCSI storage.

## Containerization and Kubernetes

### Sum Microservice
Python-based sum service packaged using Docker.

### Kubernetes Sum Service
Containerized sum application accompanied by a Kubernetes deployment manifest.

### Chain Microservices
Multiple Python microservices (`add1` and `add2`) designed for a multi-service application workflow.

### Container Networking
Docker image configurations for connectivity and container networking experiments.

## Backup and Reproducibility

Complete VMware virtual machines are archived separately in private cloud storage. This repository contains selected source code and configuration files, not the virtual machine disks.

**Documentation status:** File descriptions are preliminary and should be updated after examining the scripts and verifying their behavior.
