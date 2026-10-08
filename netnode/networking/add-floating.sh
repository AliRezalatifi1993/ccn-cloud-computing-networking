# Floating IP 
VM_ADDR=$1
FLOATING_ADDR=$2
NET_NS=$3
QG_INT=$4

# Example
# VM_ADDR = 192.168.1.57
# FLOATING_ADDR = 192.168.96.25
# NET_NS = qrtr-vnet2
# QG_INT = qgway-vnet2-tap
# ./add-floating.sh "192.168.1.57" "192.168.96.25" "qrtr-vnet1" "qgway-vnet1-tap"


ip netns exec $NET_NS ip a a $FLOATING_ADDR/32 dev $QG_INT
ip netns exec $NET_NS iptables -t nat -I POSTROUTING 1 -o $QG_INT -s $VM_ADDR/32  -j SNAT --to-source $FLOATING_ADDR
ip netns exec $NET_NS iptables -t nat -A PREROUTING -i $QG_INT -d $FLOATING_ADDR/32  -j DNAT --to-destination $VM_ADDR

