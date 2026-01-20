# Developer Documentation (DEV_DOC)

## Overview
This project uses Docker and Docker Compose to run a 3-service stack:
- MariaDB database
- WordPress (PHP-FPM)
- NGINX (TLS termination + serving the WordPress site)

The entry points are:
- `Makefile` (orchestrates Compose)
- `srcs/docker-compose.yml` (services/networks/secrets/mounts)

## Environment setup from scratch

### Prerequisites
- Docker Engine
- Docker Compose v2 (available as `docker compose`)
- GNU Make

### Configuration files

#### Environment variables
File: `srcs/.env`

This file is loaded by Compose via `--env-file srcs/.env` (see `Makefile`).

It defines values like:
- `MYSQL_DATABASE`, `MYSQL_USER`
- `WP_TITLE`, `WP_ADMIN`, `WP_ADMIN_EMAIL`, `WP_USER`, `WP_USER_EMAIL`
- `DOMAIN_NAME`

#### Secrets
Directory: `srcs/secrets/`

These files are referenced in `srcs/docker-compose.yml` under `secrets:` and mounted into containers under `/run/secrets/...`.

Required secret files:
- `srcs/secrets/db_root_password.txt`
- `srcs/secrets/db_password.txt`
- `srcs/secrets/wp_admin_password.txt`
- `srcs/secrets/wp_user_password.txt`

### Data directories (persistence)
The stack persists data on the host using bind mounts (see `srcs/docker-compose.yml`).

Current configured host paths:
- MariaDB: `/home/mokutucu/data/mariadb` mounted to `/var/lib/mysql`
- WordPress: `/home/mokutucu/data/wordpress` mounted to `/var/www/wordpress`

The `Makefile` creates these folders in the `up` target.

If you run this project under a different username/path (or on a VM), update:
- `DATA_DIR` in `Makefile`
- the bind mount paths in `srcs/docker-compose.yml`

## Build and launch

From the repository root:
- Build + start: `make up`

What `make up` does:
- ensures the host bind-mount directories exist
- runs: `docker compose -p srcs --env-file srcs/.env -f srcs/docker-compose.yml up -d --build`

Stop:
- `make down`

Cleanup:
- `make clean` (Compose down + volumes)
- `make fclean` (aggressive cleanup + delete data directories)

## Useful Docker/Compose commands

### Status
- `docker compose -p srcs -f srcs/docker-compose.yml ps`
- `docker ps`

### Logs
- `docker compose -p srcs -f srcs/docker-compose.yml logs -f`
- `docker logs -f srcs-mariadb-1`

### Rebuild specific service
- `docker compose -p srcs -f srcs/docker-compose.yml build mariadb`
- `docker compose -p srcs -f srcs/docker-compose.yml up -d mariadb`

### Exec into a container
- `docker exec -it srcs-mariadb-1 bash`
- `docker exec -it srcs-wordpress-1 bash`
- `docker exec -it srcs-nginx-1 bash`

### Volumes and stored data
This project uses bind mounts, so most persistent data is directly under the host paths described above.

Still useful:
- `docker volume ls`
- `docker system df`

## Common dev pitfalls

### Rootless Docker and port 443
If Docker runs in rootless mode, publishing `443:443` may fail because ports `<1024` are privileged.
Fixes:
- change to a high port (e.g. `8443:443`) in `srcs/docker-compose.yml`, or
- run in a VM/rootful Docker, or
- apply sysctl/capability changes (requires admin privileges).

### Disk space and bind mounts
MariaDB initialization fails if the filesystem backing the bind mount is full.
Check:
- `df -h /home/<user>`

Move your bind mount directory to a filesystem with space and update the paths accordingly.
