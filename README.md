*This project has been created as part of the 42 curriculum by mokutucu.*

# Inception

## Description
This repository contains a small infrastructure stack built with Docker and Docker Compose (the 42 “Inception” project).

**Goal**: run a WordPress website served by NGINX over TLS, backed by a MariaDB database, with each component running in its own container and connected through a private Docker network.

**What’s included**
- **NGINX** container acting as the HTTPS reverse proxy / web server.
- **WordPress + PHP-FPM** container running the WordPress application.
- **MariaDB** container providing the database.
- A **Compose file** that wires networking, volumes/bind mounts, and secrets.

## Project Structure
- `Makefile`: helper targets to start/stop and clean the stack.
- `srcs/docker-compose.yml`: service definitions (nginx/wordpress/mariadb), network, secrets, mounts.
- `srcs/.env`: non-secret configuration (DB name/user, WP metadata, domain).
- `srcs/secrets/`: secret files mounted as Docker secrets (passwords).
- `srcs/requirements/*`: Dockerfiles and config/scripts per service.

## Instructions

### Prerequisites
- Docker Engine
- Docker Compose v2 (`docker compose`)
- `make`

### Configure environment
1) Edit `srcs/.env` to match your desired settings (domain name, WP users, etc.).

2) Ensure the secret files exist under `srcs/secrets/`:
- `srcs/secrets/db_root_password.txt`
- `srcs/secrets/db_password.txt`
- `srcs/secrets/wp_admin_password.txt`
- `srcs/secrets/wp_user_password.txt`

Each file should contain **only** the password (no quotes, no extra lines).

### Run
From the repository root:
- Start and build: `make up`
- Stop containers: `make down`
- Stop and remove volumes: `make clean`
- Remove *everything* + delete local data directory: `make fclean`

### Data persistence
By default this project persists state on the host using bind mounts:
- MariaDB data: `/home/mokutucu/data/mariadb`
- WordPress files: `/home/mokutucu/data/wordpress`

These paths are created by the `Makefile` and referenced by `srcs/docker-compose.yml`. If you are not using the same username/path, update:
- `DATA_DIR` in `Makefile`
- the bind mount paths in `srcs/docker-compose.yml`

### Notes (rootless Docker / privileged ports)
If you are using **rootless Docker**, binding to port `443` may fail (ports `<1024` are privileged). If that happens you can:
- change the published port in `srcs/docker-compose.yml` (e.g. `"8443:443"`), or
- switch to a VM / rootful Docker, or
- adjust host sysctl/capabilities (requires admin privileges).

## Design Choices and Comparisons

### Virtual Machines vs Docker
- **VMs** package an entire OS kernel + userspace per machine. They are heavier, boot slower, and generally use more resources, but provide stronger isolation and a very “full system” environment.
- **Docker containers** share the host kernel and isolate processes via namespaces/cgroups. They start quickly and are lightweight, which is great for multi-service stacks, but they depend on host kernel features and can behave differently depending on rootless vs rootful setups.

### Secrets vs Environment Variables
- **Environment variables** are convenient for non-sensitive configuration (domain name, WP title, DB name/user). They are easy to override and are visible to processes inside the container.
- **Secrets** are intended for sensitive values (passwords, tokens). In this project, passwords are stored in files under `srcs/secrets/` and mounted into containers under `/run/secrets/...`. The containers read the password values from those files.

Why both?
- Keep *public configuration* in `srcs/.env`.
- Keep *credentials* out of `.env` and supply them via secrets.

### Docker Network vs Host Network
- **Docker bridge networks** (what this project uses) provide a private DNS and isolated communication between containers (service names like `mariadb` resolve automatically). You can selectively publish only the ports you want exposed to the host.
- **Host network** makes the container share the host’s network stack. It’s simple for performance/port access, but removes isolation and can lead to port collisions and less predictable behavior.

### Docker Volumes vs Bind Mounts
- **Named Docker volumes** are managed by Docker. They’re convenient and portable, and Docker handles the storage location.
- **Bind mounts** map an explicit host path into the container (used here). They make it easy to find/inspect data on the host and match typical 42 project expectations, but require correct host permissions and enough disk space on the target filesystem.

## Resources

### Technical references
- Docker overview: https://docs.docker.com/get-started/
- Docker Compose: https://docs.docker.com/compose/
- Docker secrets (Compose): https://docs.docker.com/compose/use-secrets/
- NGINX documentation: https://nginx.org/en/docs/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- WordPress: https://wordpress.org/documentation/
- WP-CLI: https://wp-cli.org/

### How AI was used
AI (GPT-5.2 via GitHub Copilot) was used as a productivity aid for:
- diagnosing Docker/Compose runtime issues (rootless Docker restrictions, disk/volume behavior),
- suggesting safe configuration patterns (secrets vs env, network topology),
- drafting this `README.md` based on the repository’s current structure and configuration.
