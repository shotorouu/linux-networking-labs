# Nginx L7 Routing Lab
This project demonstrates Layer 7 (Application Layer) load balancing 
and reverse proxying using Nginx within an isolated Docker network. 
It showcases routing traffic based on request URIs (/ vs /api/), protocol upgrading (HTTP to HTTPS redirection), 
and load balancing across multiple backend instances.

## Network architecture
The lab provisions an isolated docker network containing six containers:

nginx_lb-1 (10.15.0.100): The cwntral entrypoint. Acting as the reverse proxy and also L7 load balancer.

backend_1 (10.15.0.11) Primary, high capacity server
backend_2 (10.15.0.12): Secondary server
backend_3 (10.15.0.13): Backup server.

api_1 (10.15.0.14): Primary API server handling /api/ traffic.
api_2 (10.15.0.15): Secondary API server handling /api/ traffic.

# Key Features
HTTP to HTTPS redirection: port 80 automatically issues a 301 Moved permanently to upgrade connections securely to port 443
Path-Based Routing: traffic is split at L7; requests containing /api/ target a dedicated upstream group, while all other requests hitting / go to the primary backend pool
Weighted Load Balancing: state distribution favoring high-capacity nodes (weight=4 on backend_1)

Spin up the isolated environment and test it using the following commands:
```
docker compose up -d 
curl -i http://10.15.0.100 # should be moved permanently 301
curl -k -i https://10.15.0.100 # backend secure 200
curl -k -i https://10.15.0.100/api/ # api secure 200
```

You can see all the photos below and also in ./images:

