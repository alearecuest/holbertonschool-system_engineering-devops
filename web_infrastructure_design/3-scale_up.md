# Scale Up – Distributed and Split Web Infrastructure for www.foobar.com

## Overview
This design scales the previous infrastructure by adding:
- **One additional server** to separate roles.
- **A second load balancer (HAProxy)** configured in a cluster with the first for high availability.
- **Split components**: web server, application server, and database each on their own dedicated server.

---

## User journey from browser to response
1. **User opens browser** and types `www.foobar.com`.
2. **DNS resolution:** The `www` A record points to the public IP of the load balancer cluster (virtual IP managed by HAProxy pair).
3. **HTTPS connection:** The browser establishes a TLS session with the active load balancer.
4. **Load balancing:** The active HAProxy forwards the request to the web server according to the configured algorithm.
5. **Web server (Nginx):** Serves static content or forwards dynamic requests to the application server.
6. **Application server:** Executes business logic using the application files and queries the database server.
7. **Database server (MySQL):** Processes reads/writes and returns data to the application server.
8. **Response:** The application server sends the processed content back to Nginx, which returns it through HAProxy to the user.

---

## Additional elements and why they are added
- **Second load balancer (HAProxy cluster):**  
  - Provides high availability for the load balancing tier.  
  - If one load balancer fails, the other takes over via a shared virtual IP (failover).
- **Dedicated web server:**  
  - Optimized for serving static assets and handling HTTP(S) requests.  
  - Reduces load on application and database servers.
- **Dedicated application server:**  
  - Runs backend logic and processes dynamic requests.  
  - Isolated from web server to allow independent scaling and security hardening.
- **Dedicated database server:**  
  - Stores and retrieves structured data.  
  - Isolated for performance and security; can be tuned independently.

---

## Application server vs Web server
- **Web server (Nginx):**  
  - Handles HTTP/HTTPS requests from clients.  
  - Serves static files (HTML, CSS, JS, images).  
  - Proxies dynamic requests to the application server.
- **Application server:**  
  - Executes backend code (business logic, templates, API endpoints).  
  - Communicates with the database to fetch or update data.  
  - Returns processed responses to the web server.

---

## ASCII “whiteboard” diagram

```
User Browser
    |
    |  DNS Lookup (A record: www.foobar.com -> LB Cluster VIP)
    v
Internet
    |
    v
[ HAProxy LB1 ] <----> [ HAProxy LB2 ]   (Cluster / Failover)
    |
    |  (Round Robin / Least Connections)
    v
[ Web Server: Nginx ]
    |
    v
[ Application Server ]
    |
    v
[ Database Server: MySQL ]

```

---

## Notes
- **Load balancer cluster:** Uses VRRP or similar protocol to share a virtual IP; one active, one standby (Active-Passive) or both active (Active-Active) depending on configuration.
- **Scaling:** Each tier can be scaled horizontally or vertically without affecting others.
- **Security:** Firewalls and HTTPS should be maintained between tiers.
- **Monitoring:** Each server should have monitoring agents to track performance and availability.
