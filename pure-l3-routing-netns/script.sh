#!/bin/bash

# Phase 1 (Network topology and L2 links)

ip netns add ns_1
ip netns add ns_2
ip netns add ns_3

ip link add veth-a1 type veth peer veth-a2
ip link add veth-b1 type veth peer veth-b2


ip link set veth-b2 netns ns_3
ip link set veth-b1 netns ns_2
ip link set veth-a2 netns ns_3
ip link set veth-a1 netns ns_1

# Phase 2 (L3 addressing and subnet design)

# Subnets
# 172.16.0.0/16 # initially net
# 172.16.0.0/17
# 172.16.128.0/17

ip netns exec ns_3 ip a add 172.16.0.1/17 dev veth-a2
ip netns exec ns_3 ip a add 172.16.128.1/17 dev veth-b2
ip netns exec ns_1 ip a add 172.16.0.2/17 dev veth-a1
ip netns exec ns_2 ip a add 172.16.128.2/17 dev veth-b1

ip netns exec ns_3 ip link set veth-b2 up
ip netns exec ns_3 ip link set veth-a2 up
ip netns exec ns_1 ip link set veth-a1 up
ip netns exec ns_2 ip link set veth-b1 up

# Phase 3 (Routing configuration)

ip netns exec ns_1 ip route add default via 172.16.0.1 dev veth-a1
ip netns exec ns_2 ip route add default via 172.16.128.1 dev veth-b1
sysctl -w net.ipv4.ip_forward=1

# Phase 4 (Verification and protocol analysis)

ip netns exec ns_3 tcpdump -nni any icmp or arp -c 6 > router.log 2>&1 &
ip netns exec ns_1 ping -c 3 172.16.128.2

ip netns exec ns_1 ip neighbor show
ip netns exec ns_2 ip neighbor show
cat router.log
