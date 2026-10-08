#cleaning

ip netns exec qd-vnetred ip link set qd-vnetred-tap netns 1
ip netns del qd-vnetred
ovs-vsctl del-port br-int qd-vnetred-tap

vnet2-dhcp.confip netns exec qd-vnetblu ip link set qd-vnetblu-tap netns 1
ip netns del qd-vnetblu
ovs-vsctl del-port br-int qd-vnetblu-tap

#create-namespaces
ip netns add qd-vnetred
ip netns add qd-vnetblu

#ports

ovs-vsctl add-port br-int qd-vnetred-tap tag=100 -- set  interface qd-vnetred-tap type=internal
ovs-vsctl add-port br-int qd-vnetblu-tap tag=200 -- set  interface qd-vnetblu-tap type=internal

# -------------------------
# DHCP for red and blu
# -------------------------

ip link set qd-vnetred-tap netns qd-vnetred
ip netns exec qd-vnetred ip link set qd-vnetred-tap up
ip netns exec qd-vnetred ip link set mtu 1451 dev qd-vnetred-tap
ip netns exec qd-vnetred ip a a 192.168.0.2/24 dev qd-vnetred-tap
ip netns exec qd-vnetred dnsmasq -C ./vnetred-dhcp.conf

ip link set qd-vnetblu-tap netns qd-vnetblu
ip netns exec qd-vnetblu ip link set qd-vnetblu-tap up
ip netns exec qd-vnetblu ip link set mtu 1450 dev qd-vnetblu-tap
ip netns exec qd-vnetblu ip a a 192.168.1.2/24 dev qd-vnetblu-tap
ip netns exec qd-vnetblu dnsmasq -C ./vnetblu-dhcp.conf

# -------------------------
# Variables
# -------------------------

GW_ADDR=192.168.96.2

RRED_ADDR=192.168.0.1
RRED_EXT_ADDR=192.168.96.10

RBLU_ADDR=192.168.1.1
RBLU_EXT_ADDR=192.168.96.11

# -------------------------
# cleaning red gateway
# -------------------------

ip netns exec qr-vnetred ip link set qg-vnetred-tap netns 1 2>/dev/null
ip netns exec qr-vnetred ip link set qr-vnetred-tap netns 1 2>/dev/null
ip netns del qr-vnetred 2>/dev/null
ovs-vsctl --if-exists del-port br-int qr-vnetred-tap
ovs-vsctl --if-exists del-port br-int qg-vnetred-tap


# -------------------------
# cleaning blue gateway
# -------------------------

ip netns exec qr-vnetblu ip link set qg-vnetblu-tap netns 1 2>/dev/null
ip netns exec qr-vnetblu ip link set qr-vnetblu-tap netns 1 2>/dev/null
ip netns del qr-vnetblu 2>/dev/null
ovs-vsctl --if-exists del-port br-int qr-vnetblu-tap
ovs-vsctl --if-exists del-port br-int qg-vnetblu-tap


# -------------------------
# RED router namespace
# -------------------------

ip netns add qr-vnetred

# internal red router port - tag 100
ovs-vsctl add-port br-int qr-vnetred-tap tag=100 -- set interface qr-vnetred-tap type=internal
ip link set qr-vnetred-tap netns qr-vnetred
ip netns exec qr-vnetred ip link set lo up
ip netns exec qr-vnetred ip link set qr-vnetred-tap up
ip netns exec qr-vnetred ip link set mtu 1450 dev qr-vnetred-tap
ip netns exec qr-vnetred ip addr add $RRED_ADDR/24 dev qr-vnetred-tap

# external red router port - tag 3
ovs-vsctl add-port br-int qg-vnetred-tap tag=3 -- set interface qg-vnetred-tap type=internal
ip link set qg-vnetred-tap netns qr-vnetred
ip netns exec qr-vnetred ip link set qg-vnetred-tap up
ip netns exec qr-vnetred ip link set mtu 1450 dev qg-vnetred-tap
ip netns exec qr-vnetred ip addr add $RRED_EXT_ADDR/24 dev qg-vnetred-tap

# routing + NAT
ip netns exec qr-vnetred ip route add default via $GW_ADDR
ip netns exec qr-vnetred sysctl -w net.ipv4.ip_forward=1
ip netns exec qr-vnetred iptables -t nat -A POSTROUTING -o qg-vnetred-tap -j SNAT --to-source $RRED_EXT_ADDR


# -------------------------
# BLUE router namespace
# -------------------------

ip netns add qr-vnetblu

# internal blue router port - tag 200
ovs-vsctl add-port br-int qr-vnetblu-tap tag=200 -- set interface qr-vnetblu-tap type=internal
ip link set qr-vnetblu-tap netns qr-vnetblu
ip netns exec qr-vnetblu ip link set lo up
ip netns exec qr-vnetblu ip link set qr-vnetblu-tap up
ip netns exec qr-vnetblu ip link set mtu 1450 dev qr-vnetblu-tap
ip netns exec qr-vnetblu ip addr add $RBLU_ADDR/24 dev qr-vnetblu-tap

# external blue router port - tag 3
ovs-vsctl add-port br-int qg-vnetblu-tap tag=3 -- set interface qg-vnetblu-tap type=internal
ip link set qg-vnetblu-tap netns qr-vnetblu
ip netns exec qr-vnetblu ip link set qg-vnetblu-tap up
ip netns exec qr-vnetblu ip link set mtu 1450 dev qg-vnetblu-tap
ip netns exec qr-vnetblu ip addr add $RBLU_EXT_ADDR/24 dev qg-vnetblu-tap

# routing + NAT
ip netns exec qr-vnetblu ip route add default via $GW_ADDR
ip netns exec qr-vnetblu sysctl -w net.ipv4.ip_forward=1
ip netns exec qr-vnetblu iptables -t nat -A POSTROUTING -o qg-vnetblu-tap -j SNAT --to-source $RBLU_EXT_ADDR
