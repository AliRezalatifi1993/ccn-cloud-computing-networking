#!/bin/bash

TARGET_ID=1
TARGET_NAME="iqn.2009-02.com.example:for.all"
LUN_ID=1
LUN_DEV="/dev/cinder-volumes/tc1-redlvm"

sudo systemctl start tgt

# create target if not already created
sudo tgtadm --lld iscsi --mode target --op show | grep -q "$TARGET_NAME" || \
sudo tgtadm --lld iscsi --mode target --op new --tid=$TARGET_ID --targetname $TARGET_NAME

# allow all clients
sudo tgtadm --lld iscsi --mode target --op bind --tid $TARGET_ID -I ALL 2>/dev/null

# add LUN if not already added
sudo tgtadm --lld iscsi --mode target --op show | grep -q "$LUN_DEV" || \
sudo tgtadm --lld iscsi --mode logicalunit --op new --tid $TARGET_ID --lun $LUN_ID -b $LUN_DEV

# show result
sudo tgtadm --lld iscsi --mode target --op show
