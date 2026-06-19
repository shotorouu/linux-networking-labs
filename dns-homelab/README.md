# linux-networking-labs/dns-homelab

This is a lab for DNS practice. Main goal - create network L2 isolation, configure the host
machine as DNS and enable namespaces to utilize the host as **DNS Recursive Resolver**

I have done this project using dnsmasq. Also i used the environment preparation script and cleanup
script from the previous project 

I divided the process into three phases
1. Phase 1 - dnsmasq configuration
2. Phase 2 - resolv.conf imitation for each namespace
3. Phase 3 - iptables configuraton 

Configure the conf.env file to your needs
You can see all photos in the ".images/" directory.
