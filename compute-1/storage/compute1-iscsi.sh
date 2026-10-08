#!/bin/bash

NETNODE_IP="192.168.56.100"
TARGET_NAME="iqn.2009-02.com.example:for.all"

sudo systemctl start iscsid 2>/dev/null || sudo systemctl start open-iscsi

# discover iSCSI target from netnode
sudo iscsiadm -m discovery -t st -p $NETNODE_IP

# login to target
sudo iscsiadm --mode node --targetname "$TARGET_NAME" --portal $NETNODE_IP --login 2>/dev/null

# show connected session
sudo iscsiadm -m session

# show disk path
ls /dev/disk/by-path | grep "$NETNODE_IP"
