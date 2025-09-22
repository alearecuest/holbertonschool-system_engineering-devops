# Secured and Monitored Web Infrastructure for www.foobar.com

## User journey from browser to response
1. A user opens a browser and types `www.foobar.com`.
2. DNS resolution: The `www` A record points to the load balancer’s public IP.
3. HTTPS connection: The browser establishes a TLS session with the load balancer, validating the SSL certificate for `www.foobar.com`.
4. Load balancing: HAProxy receives the encrypted request, terminates TLS, and forwards it to one of the backend servers.
5. Web server (Nginx): Serves static files or forwards dynamic requests to the application server.
6. Application server: Executes business logic using the application files and queries the database.
7. Database: MySQL processes reads/writes (Primary handles writes, Replica handles reads if configured).
8. Response: The application server returns the content to Nginx, which sends it back through HAProxy to the user over HTTPS.

---

## Components added and why
- **Three firewalls:**  
  - Firewall 1 (perimeter): Allows only HTTPS (TCP 443) from the internet to the load balancer.  
  - Firewall 2 (application tier): Allows only load balancer-to-web server traffic; blocks direct public access.  
  - Firewall 3 (data tier): Allows only application-to-database traffic on TCP 3306.
- **SSL certificate:** Encrypts traffic between client and server, ensuring confidentiality, integrity, and authentication.
- **Three monitoring clients:** One per server to collect logs, metrics, and events for alerting and dashboards.

---

## What are firewalls for
- Control and filter network traffic based on rules.
- Protect each tier from unauthorized access.
- Reduce attack surface and segment the infrastructure.

---

## Why traffic is served over HTTPS
- Encrypts data in transit to prevent eavesdropping.
- Ensures data integrity and authenticity.
- Meets security best practices and compliance requirements.

---

## What monitoring is used for
- Detects outages and performance issues early.
- Tracks resource usage for scaling decisions.
- Provides visibility into security events.
- Helps diagnose incidents via logs and metrics correlation.

---

## How the monitoring tool collects data
- Agents on each server gather logs (HAProxy, Nginx, application, MySQL) and metrics (CPU, RAM, disk, network).
- Data is securely sent to a monitoring backend (e.g., Sumo Logic, Prometheus).
- Metrics and logs are tagged for accurate dashboards and alerts.

---

## How to monitor web server QPS
- Enable Nginx `stub_status` or HAProxy stats to expose request counters.
- Monitoring agents scrape counters periodically and compute per-second rates.
- Visualize QPS in dashboards and set alerts for abnormal spikes or drops.

---

## ASCII “whiteboard” diagram

```
User Browser
    |
    |  DNS Lookup (A record: www.foobar.com -> LB Public IP)
    v
Internet
    |
    v
[ Firewall 1: Perimeter ]
    |
    v
[ Load Balancer: HAProxy ] --(SSL termination: HTTPS in, HTTP/TLS internal)--
    | (Round Robin / Least Connections)
    +---------------------+
    |                     |
    v                     v
[ Firewall 2: App tier ]  [ Firewall 2: App tier ]
    |                     |
    v                     v
[ Server 1 ]              [ Server 2 ]
    ├── Nginx (Web Server)
    ├── Application Server
    ├── Application Files (Code Base)
    └── MySQL (Primary or Replica)
         |
         v
     [ Firewall 3: Data tier ]
         |
         v
     [ MySQL Primary / Replica access control ]

Monitoring clients:
- LB server: HAProxy metrics/logs
- Server 1: Nginx/app/MySQL metrics/logs
- Server 2: Nginx/app/MySQL metrics/logs
```

---

## Issues with this infrastructure
- **SSL termination at the load balancer:** If TLS is not re‑established internally, traffic between LB and backend is unencrypted.
- **Only one MySQL server accepting writes:** The Primary is a single point for write availability; failure stops all writes until failover.
- **Servers with all components:** Mixing DB, web, and app roles on each server increases attack surface, complicates scaling, and risks data inconsistency.

---

## Notes
- Prefer re‑encrypting traffic from LB to backend servers.
- Use deny‑by‑default firewall rules.
- Add monitoring for QPS, latency, error rates, CPU/memory, and DB replication lag.
