# Web infrastructure design

# Simple web stack – Task 0

This repository contains a one-server web infrastructure design for `www.foobar.com`, including:

- Domain name `foobar.com` with a `www` A record pointing to `8.8.8.8`
- One server hosting:
  - Nginx (web server)
  - Application server
  - Application files (code base)
  - MySQL (database)

Files:
- `0-simple_web_stack.md`: Complete English explanation for presentation.
- `diagram.txt`: ASCII “whiteboard” diagram of the architecture.

Key points covered:
- What a server is
- Role of the domain name
- Type of DNS record for `www`
- Roles of web server, application server, database
- Protocol used between server and user’s computer
- Issues: SPOF, maintenance downtime, no scaling
