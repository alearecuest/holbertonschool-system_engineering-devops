# Simple web stack for www.foobar.com

## User journey from browser to response
- **Start:** A user opens a browser and types `www.foobar.com`.
- **DNS resolution:** The browser asks DNS for the IP of `www.foobar.com`. The `www` DNS **A record** maps `www.foobar.com` to the server IP `8.8.8.8`.
- **Connection:** The browser opens a TCP connection to `8.8.8.8` and sends an HTTP/HTTPS request over **TCP/IP**.
- **Web server (Nginx):** Nginx receives the request. It serves static files directly and forwards dynamic requests to the application server.
- **Application server:** Executes the application code (business logic), often via PHP-FPM, Node.js, or a Python WSGI server. If data is needed, it queries the MySQL database.
- **Database (MySQL):** Returns requested data (e.g., user profiles, posts). The application server uses the data to build a response.
- **Response:** The application server returns the processed content to Nginx, which sends the final HTML/CSS/JS back to the user’s browser for rendering.

## What each component is and does
- **Server:** A physical or virtual machine that hosts all services for the website (web server, application server, application files, database). It’s reachable at IP `8.8.8.8`.
- **Domain name (`foobar.com`):** A human-readable address that points to an IP, allowing users to access the website without remembering numeric addresses.
- **DNS record for `www`:** `www` is a **subdomain** of `foobar.com`. Its DNS record is an **A record**, mapping `www.foobar.com` to the IPv4 address `8.8.8.8`.
- **Web server (Nginx):** Handles HTTP(S) requests, serves static assets efficiently, terminates TLS when HTTPS is used, and proxies dynamic requests to the application server.
- **Application server:** Runs the backend logic (routes, controllers, templates), talks to the database, and constructs dynamic responses. Examples: PHP-FPM with Nginx, Node.js processes, Python WSGI (Gunicorn/uWSGI).
- **Application files (code base):** Your source code, configuration, templates, and static assets that implement the site’s features and business rules.
- **Database (MySQL):** Persists and indexes structured data (users, sessions, content, transactions) and supports queries for reads/writes.

## Protocol between server and user’s computer
- **HTTP/HTTPS over TCP/IP:** The browser and server communicate via the HTTP protocol (or HTTPS with TLS for security) transported over TCP on top of IP.

## ASCII “whiteboard” diagram

```
User Browser
    |
    |  DNS Lookup (A record: www.foobar.com -> 8.8.8.8)
    v
Internet
    |
    v
[ Server: 8.8.8.8 ]
    ├── Nginx (Web Server)
    ├── Application Server
    ├── Application Files (Code Base)
    └── MySQL Database
```

## Issues with this one-server infrastructure
- **Single Point of Failure (SPOF):** All components are on one machine. If the server fails, the entire website is unavailable.
- **Downtime during maintenance:** Deploying new code, updating packages, or restarting Nginx/MySQL can interrupt service and cause downtime.
- **Cannot scale with high traffic:** One server has limited CPU, RAM, disk I/O, and network bandwidth. Traffic spikes can degrade performance or cause timeouts.

## Notes and typical implementation choices
- **Nginx + PHP-FPM (L(E)MP):** Common pairing for PHP apps; Nginx proxies `.php` requests to PHP-FPM sockets/ports.
- **Node.js or Python:** Nginx reverse-proxies to an upstream (e.g., Node.js on `127.0.0.1:3000`, or Gunicorn on `127.0.0.1:8000`).
- **MySQL access:** Application uses credentials and a connection string (host: `127.0.0.1`, port: `3306`) to read/write data.
- **Security (HTTPS):** Add TLS certs at Nginx for HTTPS; still a single server, but improves confidentiality and integrity.
