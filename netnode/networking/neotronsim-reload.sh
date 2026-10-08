#cleaning

ip netns exec qdhcp-vnet2 ip link set qdhcp-vnet2-tap netns 1
ip netns del qdhcp-vnet2
ovs-vsctl del-port br-int qdhcp-vnet2-tap

ip netns exec qdhcp-vnet1 ip link set qdhcp-vnet1-tap netns 1
ip netns del qdhcp-vnet1
ovs-vsctl del-port br-int qdhcp-vnet1-tap

#create-namespaces-for-DHCP
ip netns add qdhcp-vnet2
ip netns add qdhcp-vnet1

#ports

ovs-vsctl add-port br-int qdhcp-vnet2-tap tag=200 -- set interface qdhcp-vnet2-tap type=internal
ovs-vsctl add-port br-int qdhcp-vnet1-tap tag=100 -- set interface qdhcp-vnet1-tap type=internal

#-------------------
# DHCP apply for vnet1 and vnet2
#-------------------

ip link set qdhcp-vnet2-tap netns qdhcp-vnet2
ip netns exec qdhcp-vnet2 ip link set qdhcp-vnet2-tap up
ip netns exec qdhcp-vnet2 ip link set mtu 1450 dev qdhcp-vnet2-tap
ip netns exec qdhcp-vnet2 ip a a 192.168.2.2/24 dev qdhcp-vnet2-tap
ip netns exec qdhcp-vnet2 dnsmasq -C ./vnet2-dhcp.conf

ip link set qdhcp-vnet1-tap netns qdhcp-vnet1
ip netns exec qdhcp-vnet1 ip link set qdhcp-vnet1-tap up
ip netns exec qdhcp-vnet1 ip link set mtu 1450 dev qdhcp-vnet1-tap
ip netns exec qdhcp-vnet1 ip a a 192.168.1.2/24 dev qdhcp-vnet1-tap
ip netns exec qdhcp-vnet1 dnsmasq -C ./vnet1-dhcp.conf


#-------------------
# IP Addresses variables
#-------------------

GW_ADDR=192.168.96.2

ROUTER_VNET2_ADDR=192.168.2.1
R2_EXT_ADDR=192.168.96.10

ROUTE_NET1_ADDR=192.168.1.1
R1_EXT_ADDR=192.168.96.11

#-------------------
# cleaning net1 gateway
#-------------------

ip netns exec qrtr-vnet1 ip link set qgway-vnet1-tap netns 1 2>/dev/null
ip netns exec qrtr-vnet1 ip link set qrtr-vnet1-tap netns 1 2>/dev/null
ip netns del qrtr-vnet1 2>/dev/null
ovs-vsctl --if-exists del-port br-int qgway-vnet1-tap
ovs-vsctl --if-exists del-port br-int qrtr-vnet1-tap

#-------------------
# cleaning net2 gateway
#-------------------

ip netns exec qrtr-vnet2 ip link set qgway-vnet2-tap netns 1 2>/dev/null
ip netns exec qrtr-vnet2 ip link set qrtr-vnet2-tap netns 1 2>/dev/null
ip netns del qrtr-vnet2 2>/dev/null
ovs-vsctl --if-exists del-port br-int qgway-vnet2-tap
ovs-vsctl --if-exists del-port br-int qrtr-vnet2-tap



#-------------------
# vnet1 router namespace
#-------------------

ip netns add qrtr-vnet1

# internal vnet1 router port - tag 100
ovs-vsctl add-port br-int qrtr-vnet1-tap tag=100 -- set interface qrtr-vnet1-tap type=internal
ip link set qrtr-vnet1-tap netns qrtr-vnet1
ip netns exec qrtr-vnet1 ip link set lo up
ip netns exec qrtr-vnet1 ip link set qrtr-vnet1-tap up
ip netns exec qrtr-vnet1 ip link set mtu 1450 dev qrtr-vnet1-tap
ip netns exec qrtr-vnet1 ip addr add $ROUTE_NET1_ADDR/24 dev qrtr-vnet1-tap

# external vnet1 router port - tag 3
ovs-vsctl add-port br-int qgway-vnet1-tap tag=3 -- set interface qgway-vnet1-tap type=internal
ip link set qgway-vnet1-tap netns qrtr-vnet1
ip netns exec qrtr-vnet1 ip link set qgway-vnet1-tap up
ip netns exec qrtr-vnet1 ip link set mtu 1450 dev qgway-vnet1-tap
ip netns exec qrtr-vnet1 ip addr add $R1_EXT_ADDR/24 dev qgway-vnet1-tap

# routing - NAT
ip netns exec qrtr-vnet1 ip route add default via $GW_ADDR
ip netns exec qrtr-vnet1 sysctl -w net.ipv4.ip_forward=1
ip netns exec qrtr-vnet1 iptables -t nat -A POSTROUTING -o qgway-vnet1-tap -j SNAT --to-source $R1_EXT_ADDR


#-------------------
# vnet2 router namespace
#-------------------

ip netns add qrtr-vnet2

# internal vnet2 router port - tag 200
ovs-vsctl add-port br-int qrtr-vnet2-tap tag=200 -- set interface qrtr-vnet2-tap type=internal
ip link set qrtr-vnet2-tap netns qrtr-vnet2
ip netns exec qrtr-vnet2 ip link set lo up
ip netns exec qrtr-vnet2 ip link set qrtr-vnet2-tap up
ip netns exec qrtr-vnet2 ip link set mtu 1450 dev qrtr-vnet2-tap
ip netns exec qrtr-vnet2 ip addr add $ROUTER_VNET2_ADDR/24 dev qrtr-vnet2-tap

# external vnet2 router port - tag 3
ovs-vsctl add-port br-int qgway-vnet2-tap tag=3 -- set interface qgway-vnet2-tap type=internal
ip link set qgway-vnet2-tap netns qrtr-vnet2
ip netns exec qrtr-vnet2 ip link set qgway-vnet2-tap up
ip netns exec qrtr-vnet2 ip link set mtu 1450 dev qgway-vnet2-tap
ip netns exec qrtr-vnet2 ip addr add $R2_EXT_ADDR/24 dev qgway-vnet2-tap

# routing - NAT
ip netns exec qrtr-vnet2 ip route add default via $GW_ADDR
ip netns exec qrtr-vnet2 sysctl -w net.ipv4.ip_forward=1
ip netns exec qrtr-vnet2 iptables -t nat -A POSTROUTING -o qgway-vnet2-tap -j SNAT --to-source $R2_EXT_ADDR


                                                                                                                    




