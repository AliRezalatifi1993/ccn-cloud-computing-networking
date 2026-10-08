# VXLAN initial br-tun setup
#ovs-vsctl add-br br-tun
#create the patch
#ovs-vsctl add-port br-tun patch-int -- set interface patch-int type=patch options:peer=patch-tun
#ovs-vsctl add-port br-int patch-tun -- set interface patch-tun type=patch options:peer=patch-int

#setup the VXLAN MESH

compute2="192.168.56.102"
#ovs-vsctl add-port br-tun vxlan12 -- set interface vxlan12 type=vxlan options:{remote_ip=$compute2,key=flow} 

netnode="192.168.56.100"
#ovs-vsctl add-port br-tun vxlan1n -- set interface vxlan1n type=vxlan options:{remote_ip=$netnode,key=flow}


# VXLAN autolearning on br-tun  

ovs-ofctl del-flows br-tun 

# Avoid loops
ovs-ofctl add-flow br-tun priority=0,actions=drop

# From br-int
ovs-ofctl add-flow br-tun priority=10,in_port='patch-int',dl_vlan=100,actions='set_field:0x64->tun_id',strip_vlan,NORMAL
ovs-ofctl add-flow br-tun priority=10,in_port='patch-int',dl_vlan=200,actions='set_field:0xC8->tun_id',strip_vlan,NORMAL

# From vxlan (no-autolearning)
#ovs-ofctl add-flow br-tun priority=10,in_port='vxlan12',tun_id=0x64,actions=mod_vlan_vid:100,output:'patch-int'
#ovs-ofctl add-flow br-tun priority=10,in_port='vxlan12',tun_id=0xC8,actions=mod_vlan_vid:200,output:'patch-int'
#ovs-ofctl add-flow br-tun priority=10,in_port='vxlan1n',tun_id=0x64,actions=mod_vlan_vid:100,output:'patch-int'
#ovs-ofctl add-flow br-tun priority=10,in_port='vxlan1n',tun_id=0xC8,actions=mod_vlan_vid:200,output:'patch-int'
                                                                    
# From vxlan with autolearning
ovs-ofctl add-flow br-tun priority=10,in_port='vxlan12',tun_id=0x64,actions="mod_vlan_vid:100,learn(table=0,hard_timeout=300,priority=11,cookie=0x1,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:0->NXM_OF_VLAN_TCI[],load:NXM_NX_TUN_ID[]->NXM_NX_TUN_ID[],output:OXM_OF_IN_PORT[]),output:patch-int"
ovs-ofctl add-flow br-tun priority=10,in_port='vxlan1n',tun_id=0x64,actions="mod_vlan_vid:100,learn(table=0,hard_timeout=300,priority=11,cookie=0x1,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:0->NXM_OF_VLAN_TCI[],load:NXM_NX_TUN_ID[]->NXM_NX_TUN_ID[],output:OXM_OF_IN_PORT[]),output:patch-int"
ovs-ofctl add-flow br-tun priority=10,in_port='vxlan12',tun_id=0xC8,actions="mod_vlan_vid:200,learn(table=0,hard_timeout=300,priority=11,cookie=0x1,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:0->NXM_OF_VLAN_TCI[],load:NXM_NX_TUN_ID[]->NXM_NX_TUN_ID[],output:OXM_OF_IN_PORT[]),output:patch-int" 
ovs-ofctl add-flow br-tun priority=10,in_port='vxlan1n',tun_id=0xC8,actions="mod_vlan_vid:200,learn(table=0,hard_timeout=300,priority=11,cookie=0x1,NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:0->NXM_OF_VLAN_TCI[],load:NXM_NX_TUN_ID[]->NXM_NX_TUN_ID[],output:OXM_OF_IN_PORT[]),output:patch-int"
