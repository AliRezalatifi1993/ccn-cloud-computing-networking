# VXLAN initial br-tun setup
#ovs-vsctl add-br br-tun
#ovs-vsctl add-port eth1
#create the patch
#ovs-vsctl add-port br-tun patch-int -- set interface patch-int type=patch options:peer=patch-tun
#ovs-vsctl add-port br-int patch-tun -- set interface patch-tun type=patch options:peer=patch-int

#setup the VXLAN MESH

compute1="192.168.56.101"
#ovs-vsctl add-port br-tun vxlann1 -- set interface vxlann1 type=vxlan options:{remote_ip=$compute1,key=flow} 

compute2="192.168.56.102"
#ovs-vsctl add-port br-tun vxlann2 -- set interface vxlann2 type=vxlan options:{remote_ip=$compute2,key=flow} 

compute3="192.168.56.103"
#ovs-vsctl add-port br-tun vxlann3 -- set interface vxlann3 type=vxlan options:{remote_ip=$compute3,key=flow}

# VXLAN autolearning on br-tun  

ovs-ofctl del-flows br-tun 

# Avoid loops
ovs-ofctl add-flow br-tun priority=0,actions=drop

# From br-int
ovs-ofctl add-flow br-tun priority=10,in_port='patch-int',dl_vlan=100,actions='set_field:0x64->tun_id',strip_vlan,NORMAL
ovs-ofctl add-flow br-tun priority=10,in_port='patch-int',dl_vlan=200,actions='set_field:0xc8->tun_id',strip_vlan,NORMAL

# From vxlan (no-autolearning)
#ovs-ofctl add-flow br-tun priority=10,in_port='vxlan21',tun_id=0x64,actions=mod_vlan_vid:100,output:'patch-int'
#ovs-ofctl add-flow br-tun priority=10,in_port='vxlan21',tun_id=0xc8,actions=mod_vlan_vid:200,output:'patch-int'
#ovs-ofctl add-flow br-tun priority=10,in_port='vxlan2n',tun_id=0x64,actions=mod_vlan_vid:100,output:'patch-int'
#ovs-ofctl add-flow br-tun priority=10,in_port='vxlan2n',tun_id=0xc8,actions=mod_vlan_vid:200,output:'patch-int'

# From vxlan (with-autolearning)                                                                    
ovs-ofctl add-flow br-tun priority=10,in_port='vxlann1',tun_id=0x64,actions="mod_vlan_vid:100,learn(table=0,hard_timeout=300,priority=11,cookie=0x1,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:0->NXM_OF_VLAN_TCI[],load:NXM_NX_TUN_ID[]->NXM_NX_TUN_ID[],output:OXM_OF_IN_PORT[]),output:patch-int"
ovs-ofctl add-flow br-tun priority=10,in_port='vxlann2',tun_id=0x64,actions="mod_vlan_vid:100,learn(table=0,hard_timeout=300,priority=11,cookie=0x1,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:0->NXM_OF_VLAN_TCI[],load:NXM_NX_TUN_ID[]->NXM_NX_TUN_ID[],output:OXM_OF_IN_PORT[]),output:patch-int"
ovs-ofctl add-flow br-tun priority=10,in_port='vxlann1',tun_id=0xc8,actions="mod_vlan_vid:200,learn(table=0,hard_timeout=300,priority=11,cookie=0x1,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:0->NXM_OF_VLAN_TCI[],load:NXM_NX_TUN_ID[]->NXM_NX_TUN_ID[],output:OXM_OF_IN_PORT[]),output:patch-int"
ovs-ofctl add-flow br-tun priority=10,in_port='vxlann2',tun_id=0xc8,actions="mod_vlan_vid:200,learn(table=0,hard_timeout=300,priority=11,cookie=0x1,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:0->NXM_OF_VLAN_TCI[],load:NXM_NX_TUN_ID[]->NXM_NX_TUN_ID[],output:OXM_OF_IN_PORT[]),output:patch-int"
ovs-ofctl add-flow br-tun priority=10,in_port='vxlann3',tun_id=0x64,actions="mod_vlan_vid:100,learn(table=0,hard_timeout=300,priority=11,cookie=0x1,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:0->NXM_OF_VLAN_TCI[],load:NXM_NX_TUN_ID[]->NXM_NX_TUN_ID[],output:NXM_OF_IN_PORT[]),output:patch-int"
ovs-ofctl add-flow br-tun priority=10,in_port='vxlann3',tun_id=0xC8,actions="mod_vlan_vid:200,learn(table=0,hard_timeout=300,priority=11,cookie=0x1,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:0->NXM_OF_VLAN_TCI[],load:NXM_NX_TUN_ID[]->NXM_NX_TUN_ID[],output:NXM_OF_IN_PORT[]),output:patch-int"

# Add flow entries for externa-internal (North/South) traffic ---be careful to the port numbers that may be different
# output external traffic
ovs-ofctl del-flows br-ex
ovs-ofctl add-flow br-ex priority=4,in_port=phy-br-ex,dl_vlan=3,actions=strip_vlan,NORMAL
ovs-ofctl add-flow br-ex priority=2,in_port=phy-br-ex,actions=drop
# input external traffic
ovs-ofctl add-flow br-int priority=3,in_port=int-br-ex,vlan_tci=0x0000/0x1fff,actions=mod_vlan_vid:3,NORMAL
ovs-ofctl add-flow br-ex priority=0,actions=NORMAL

