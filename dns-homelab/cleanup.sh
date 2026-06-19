#!/bin/bash
#cleanup script

source ./conf.env

systemctl stop dnsmasq

iptables -D INPUT -i "$BRIDGE_NAME" -p udp --dport 67:68 -j ACCEPT 2>/dev/null

for ns in "${NAMESPACES[@]}"; do
    ip netns del "$ns" 2>/dev/null
    ip link del "host_${ns}" 2>/dev/null
done

ip link del "$BRIDGE_NAME" 2>/dev/null
echo "Finished"

for NS in "${NAMESPACES[@]}"; do
    rm -rf /etc/netns/"$NS"
done

rm -rf /etc/dnsmasq.conf
