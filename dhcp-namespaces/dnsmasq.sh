#Namespaces
ip netns add net01
ip netns add net02
ip netns add net03

#Bridge
ip link add br0 type bridge

#Veth pairs
ip link add veth01 type veth peer host01
ip link add veth02 type veth peer host02
ip link add veth03 type veth peer host03

#Set one endpoint of veth to the namespace
ip link set veth01 netns net01
ip link set veth02 netns net02
ip link set veth03 netns net03

#We connect veth on host side to the bridge
ip link set host01 master br0
ip link set host02 master br0
ip link set host03 master br0

#On the host
ip link set host01 up
ip link set host02 up
ip link set host03 up
ip link set br0 up

#Inside the ns
ip netns exec net01 ip link set veth01 up
ip netns exec net01 ip link set lo up
ip netns exec net02 ip link set veth02 up
ip netns exec net02 ip link set lo up
ip netns exec net03 ip link set veth03 up
ip netns exec net03 ip link set lo up

#Manual assignment
#ip a add 172.22.0.1/24 dev br0

#ip netns exec net01 ip a add 172.22.0.2/24 dev veth01
#ip netns exec net02 ip a add 172.22.0.3/24 dev veth02
#ip netns exec net03 ip a add 172.22.0.4/24 dev veth03

#########################

#DHCP assignment

#Assign IP to the bridge
ip a add 172.22.0.1/24 dev br0

#Enabling UDP ports (iptables)
iptables -I INPUT -i br0 -p udp --dport 67:68 -j ACCEPT


#we will use dnsmasq as a server and dhclient as a client

#Installing a client
apt update && apt install isc-dhcp-client

#Installing a server and configuring it
apt update && apt install dnsmasq

ip netns exec net03 ip link set dev veth03 address 9e:03:d9:d6:a4:0e #3rd ns

echo "interface=br0" > /etc/dnsmasq.conf
echo "bind-interfaces" >> /etc/dnsmasq.conf
echo "dhcp-range=172.22.0.50,172.22.0.100,12h" >> /etc/dnsmasq.conf # range
echo "dhcp-host=9e:03:d9:d6:a4:0e,net03,172.22.0.99" >> /etc/dnsmasq.conf # define for 3rd ns
systemctl restart dnsmasq

#Final steps (Request and assignment, "DORA")
ip netns exec net01 dhclient veth01
ip netns exec net02 dhclient veth02
ip netns exec net03 dhclient veth03 


