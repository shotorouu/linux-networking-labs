#!/bin/bash
source ./conf.env

###### Phase 1 (DNSmasq configuration) ######
cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak # Quick backup
tee -a /etc/dnsmasq.conf << EOF

# Interface conf
listen-address=127.0.0.1,"$BRIDGE_IP_WTM"
bind-interfaces
# Sec and forwarding
domain-needed
bogus-priv
no-resolv
# Domain and local res setup
expand-hosts
domain=ali.lab
local=/ali.lab/
# Upstream DNS forwarding target
server=8.8.4.4
EOF

###### Phase 2 (Resolf.conf) #####
# Isolated resolf.conf for every NS
for NS in "${NAMESPACES[@]}"; do
    # An isolated dir for every NS
    sudo mkdir -p /etc/netns/"$NS"
    # Send ns to the bridge
    echo "nameserver $BRIDGE_IP_WTM" | sudo tee /etc/netns/"$NS"/resolv.conf
done

###### Phase 3 (Iptables configuration) ######
# Allow forwarding and enable source nat
iptables -I FORWARD 1 -i "$BRIDGE_NAME" -j ACCEPT
iptables -t nat -A POSTROUTING -s "$BRIDGE_IP" -o "$INTERFACE" -j MASQUERADE
systemctl restart dnsmasq # We must already have dnsmasq after prep.sh script
