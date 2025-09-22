# Distributed Web Infrastructure for www.foobar.com

## User journey from browser to response
1. **User opens browser** and types `www.foobar.com`.
2. **DNS resolution:** The browser queries DNS for the IP of `www.foobar.com`. The `www` A record maps to the public IP of the load balancer.
3. **Connection:** The browser connects to the load balancer via HTTP/HTTPS over TCP/IP.
4. **Load balancer (HAProxy):** Receives the request and distributes it to one of the two backend servers according to the configured algorithm.
5. **Web server (Nginx):** On the chosen backend server, Nginx handles the request, serving static files or forwarding dynamic requests to the application server.
6. **Application server:** Executes the application code (business logic) using the application files. If data is needed, it queries the MySQL database.
7. **Database cluster (Primary-Replica):** The application server writes to the Primary database and reads from either the Primary or the Replica, depending on configuration.
8. **Response:** The application server sends the processed content back to Nginx, which returns it to the load balancer, and finally to the user’s browser.

---

## Components and why they are added
- **Load balancer (HAProxy):** Distributes incoming traffic between multiple servers to improve availability and scalability.
- **Two backend servers:** Each runs Nginx, an application server, the application files, and a MySQL instance. This redundancy reduces downtime if one server fails.
- **Database Primary-Replica setup:** Improves read performance and provides redundancy for database data.

---

## Load balancer configuration
- **Distribution algorithm:** *Round Robin* — requests are sent to each backend server in turn, balancing the load evenly.
- **Active-Active setup:** Both servers are actively handling requests at the same time.  
  - **Active-Active:** All nodes serve traffic simultaneously; improves performance and redundancy.  
  - **Active-Passive:** One node handles traffic, the other is on standby and only takes over if the active node fails.

---

## Database Primary-Replica (Master-Slave) cluster
- **How it works:**  
  - The Primary node handles all write operations (INSERT, UPDATE, DELETE).  
  - The Replica node receives data updates from the Primary via replication and can serve read‑only queries.
- **Difference in application use:**  
  - **Primary:** Used for writes and sometimes reads.  
  - **Replica:** Used for read‑only queries to reduce load on the Primary.

---

## ASCII “whiteboard” diagram

```
User Browser
| 
| DNS Lookup (A record: www.foobar.com -> LB Public IP)
v 
Internet 
| 
v [ Load Balancer: HAProxy ]
| (Round Robin)
+-------------------+
| | 
v v 
[ Server 1 ] [ Server 2 ] 
├── Nginx (Web Server) 
├── Application Server 
├── Application Files (Code Base) 
└── MySQL Database 
├── Primary (Server 1) 
└── Replica (Server 2)
```

---

## Issues with this infrastructure
- **Single Points of Failure (SPOF):**
  - The load balancer itself — if it fails, the site is unreachable.
  - The Primary database — if it fails and replication is not promoted, writes cannot occur.
- **Security issues:**
  - No firewall — servers are exposed to potential attacks.
  - No HTTPS — data between client and server is not encrypted.
- **No monitoring:**
  - No system to detect failures, performance degradation, or security breaches.

---

## Notes and typical implementation choices
- **HAProxy:** Commonly used for load balancing HTTP/HTTPS traffic; supports multiple algorithms (Round Robin, Least Connections, etc.).
- **Nginx + PHP-FPM / Node.js / Python WSGI:** Backend application processing.
- **MySQL replication:** Asynchronous by default; Replica may lag behind Primary.
- **Security best practices:** Add firewalls, enable HTTPS with TLS certificates, and restrict database access.
- **Monitoring tools:** Use services like Nagios, Prometheus, or cloud monitoring to track uptime and performance.
