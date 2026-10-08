# Compute-2 — Virtualization and Networking Lab

## Overview

`compute-2` is the second Ubuntu compute node used in the Cloud Computing and Networking laboratory at the University of Rome Tor Vergata.

This node was used to study and implement virtual machines, Linux virtual networking, Open vSwitch, and communication between distributed compute nodes.

## Virtualization

| File | Description |
|---|---|
| `vminstall-kvm.sh` | Script for creating virtual machines using KVM/QEMU and libvirt. |
| `vminstall-ovs.sh` | Script intended for creating virtual machines connected through Open vSwitch networking. |
| `tc2-red.xml` | Libvirt XML configuration associated with the tc2-red virtual machine. |
| `vnet1.xml` | XML definition of a virtual network managed by libvirt. |
| `br-int-net.xml` | Libvirt network configuration associated with the Open vSwitch integration bridge. |

## Virtual Networking

| File | Description |
|---|---|
| `br-tun-reload-compute-2.sh` | Script associated with tunnel bridge configuration and distributed virtual networking on compute-2. |

## Main Technologies

- KVM/QEMU
- Libvirt and virt-install
- Linux virtual networking
- Open vSwitch
- VLAN and VXLAN
- OpenFlow

## Relation to Compute-1

Compute-1 and Compute-2 form the compute layer of the laboratory environment.

The lab studies how virtual machines hosted on different physical or virtual compute nodes can communicate through software-defined networking.

## Notes

Descriptions are preliminary and based on the course architecture. Exact commands and configuration parameters should be verified against the individual scripts.

VM disk images are not included in this repository. Complete VMware backups are stored separately.
