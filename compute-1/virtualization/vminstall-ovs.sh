#!/bin/bash
virt-install \
--name $1 \
--ram 256 \
--disk path=$2 \
--vcpus 1 \
--os-type linux \
--os-variant alpinelinux3.18 \
--network network=$3,portgroup=$4 \
--graphics none \
--console pty,target_type=serial \
--import
