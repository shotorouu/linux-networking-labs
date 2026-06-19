#!/bin/bash
source ./conf.env

####### Phase 1 (preparations)

#ns
for ns in "${NAMESPACES[@]}"; do
    ip netns add "$ns"
done

#bridge
ip link add "$BRIDGE_NAME" type bridge

#veth pairs
for ns in "${NAMESPACES[@]}"; do
    ip link add "veth_${ns}" type veth peer "host_${ns}"
    ip link set "veth_${ns}" netns "$ns"
    ip link set "host_${ns}" master "$BRIDGE_NAME"
done

#setting up the interfaces
ip link set "$BRIDGE_NAME" up
for ns in "${NAMESPACES[@]}"; do
    ip link set "host_${ns}" up
    ip netns exec "$ns" ip link set "veth_${ns}" up
    ip netns exec "$ns" ip link set lo up
done

# assign IP to the bridge
ip a add "$BRIDGE_IP" dev "$BRIDGE_NAME"

#enabling UDP ports (iptables)
iptables -I INPUT -i "$BRIDGE_NAME" -p udp --dport 67:68 -j ACCEPT

###### Phase 2 (DHCP confifuring)

#we will use dnsmasq as a server and dhclient as a client
apt update -y

apt install isc-dhcp-client dnsmasq -y &> /dev/null

ip netns exec "$STATIC_NS" ip link set dev "veth_${STATIC_NS}" address "$STATIC_MAC" #3rd ns
echo "interface=$BRIDGE_NAME" > /etc/dnsmasq.conf
echo "bind-interfaces" >> /etc/dnsmasq.conf
echo "dhcp-range=$DHCP_RANGE" >> /etc/dnsmasq.conf # range
echo "dhcp-host=$STATIC_MAC,$STATIC_NS,$STATIC_IP" >> /etc/dnsmasq.conf # defined for 3rd ns
systemctl restart dnsmasq



###### Phase 3 (Assignment)

#request and assignment, DORA
for ns in "${NAMESPACES[@]}"; do
    ip netns exec "$ns" dhclient "veth_${ns}" &> /dev/null
done

