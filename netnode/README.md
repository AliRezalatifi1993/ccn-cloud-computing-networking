# Netnode — Virtual Networking and Cloud Storage Lab

## 1. Overview

This directory contains the scripts and configurations used on **netnode**, the network and storage node of the Cloud Computing and Networking (CCN) laboratory at the University of Rome Tor Vergata.

The laboratory consists of three Ubuntu virtual machines running under VMware Workstation:

- **compute-1:** KVM virtualization, Open vSwitch networking, Docker and Kubernetes experiments.
- **compute-2:** Second compute node for distributed virtualization and virtual networking.
- **netnode:** Virtual routing, DHCP services, floating IPs, VXLAN networking and remote block storage.

The environment demonstrates several underlying technologies used by cloud platforms such as OpenStack.

## 2. Network Architecture

The lab includes two virtual networks, commonly identified by VLAN IDs 100 and 200, with VXLAN used to extend connectivity between compute nodes.

**Network components:**

- Open vSwitch integration bridges (`br-int`)
- Open vSwitch tunnel bridges (`br-tun`)
- VLAN-to-VXLAN mapping and OpenFlow rules
- Linux network namespaces for network services
- DHCP servers for assigning IP addresses
- Virtual routers and NAT
- Floating IP addresses for external connectivity

The exact interfaces, addressing and OpenFlow rules are defined by the individual configuration files and scripts.

## 3. Networking Scripts

| File | Description |
|---|---|
| `networking/add-floating.sh` | Configures floating IP functionality using Linux IP addressing and SNAT/DNAT rules. |
| `networking/br-tun-reload-netnode.sh` | Reconfigures or restores tunnel-related networking, potentially including Open vSwitch bridges and OpenFlow rules. |
| `networking/neotronsim-reload.sh` | Script associated with reloading the simulated Neutron networking environment, including network services. |
| `networking/neotronsimr.sh` | Supporting script associated with simulated Neutron networking; exact operations require inspection. |

### Floating IP

Floating IPs provide a way to reach virtual machines from outside their private network.

This generally involves:

1. Assigning an externally reachable IP address to a router interface.
2. Applying DNAT to forward incoming traffic to the VM's private address.
3. Applying SNAT to translate outgoing traffic to the floating IP address.

## 4. DHCP Configuration

The `networking/dhcp/` directory contains two DHCP configuration files.

| File | Description |
|---|---|
| `vnet1-dhcp.conf` | DHCP server configuration for virtual network 1. |
| `vnet2-dhcp.conf` | DHCP server configuration for virtual network 2. |

These files preserve the DHCP settings associated with the two virtual networks.

Depending on their contents, they may specify DHCP address ranges, network interfaces, gateway information, and other DHCP parameters.

The actual values should be documented after examining each file.

## 5. Remote Storage — iSCSI

**File:** `storage/netnode-iscsi.sh`

Netnode also acts as a storage node in the laboratory environment.

The relevant technologies are:

- Linux Logical Volume Manager (LVM)
- Physical volumes (PV)
- Volume groups (VG)
- Logical volumes (LV)
- iSCSI targets and initiators
- Persistent block storage

The goal of this lab is to demonstrate how virtual machines can access storage hosted remotely, rather than relying exclusively on local disk-image files.

The script contains the netnode-specific storage configuration.

## 6. Virtualization Files

| File | Description |
|---|---|
| `virtualization/vminstall-kvm.sh` | Script associated with creating VMs using KVM/QEMU and libvirt. |
| `virtualization/vminstall-ovs.sh` | Script intended for creating VMs connected through Open vSwitch. |
| `virtualization/tc2-red.xml` | Libvirt VM definition associated with `tc2-red`. |
| `virtualization/vnet1.xml` | XML definition of a libvirt virtual network. |
| `virtualization/br-int-net.xml` | Libvirt network definition associated with an Open vSwitch integration bridge. |

Libvirt uses XML files to describe virtual machines and virtual networking resources.

## 7. Technologies Practiced

- Linux networking and network namespaces
- Open vSwitch and OpenFlow
- VLAN and VXLAN
- Virtual DHCP services
- Routing and NAT
- Floating IP configuration
- KVM/QEMU and libvirt
- LVM and iSCSI
- Cloud infrastructure architecture

## 8. Backup and Restoration

The original scripts and configurations are preserved in this GitHub repository.

The complete VMware virtual machines, including operating systems, installed packages, virtual disks and runtime configurations, are backed up separately in private OneDrive storage.

**Important:** These scripts were created for a specific university laboratory environment. They may depend on existing interfaces, IP addresses, packages, namespaces and storage devices. Review their contents before executing them on a different machine.

## 9. Documentation Status

The explanations in this README describe the intended role of each file based on the laboratory architecture and filenames.

Detailed command-by-command documentation and exact configuration parameters will be added after inspecting the original files.
