# User Documentation (USER_DOC)

## What this stack provides
This project runs a small web stack composed of three services:

- **NGINX**: serves the website over HTTPS (TLS) and forwards PHP requests to PHP-FPM.
- **WordPress (PHP-FPM)**: runs the WordPress application.
- **MariaDB**: stores the WordPress database.

All services communicate over a private Docker network created by Docker Compose.

## Start / stop the project
Run these commands from the repository root.

- Start (build if needed): `make up`
- Stop containers: `make down`
- Stop + remove volumes (project-level cleanup): `make clean`
- Full cleanup (containers/images/volumes + delete local data directory): `make fclean`

## Accessing the website and admin panel

### Website
- The website is served by NGINX on **HTTPS**.
- With the current compose config, the container exposes **port 443** on the host.

Open:
- `https://<DOMAIN_NAME>/`

Where `<DOMAIN_NAME>` comes from `srcs/.env` (`DOMAIN_NAME=...`).

### WordPress admin panel
Open:
- `https://<DOMAIN_NAME>/wp-admin`

Log in with the **admin username** from `srcs/.env` (`WP_ADMIN=...`) and the **admin password** stored in `srcs/secrets/wp_admin_password.txt`.

> If you are using **rootless Docker**, binding to host port 443 may fail. In that case either run on a VM/rootful Docker, or change the published port in `srcs/docker-compose.yml` (e.g. map `8443:443`) and access `https://<DOMAIN_NAME>:8443/`.

## Credentials: where they are and how to manage them

### Non-secret configuration (environment variables)
File: `srcs/.env`

Contains non-sensitive configuration such as:
- database name/user (`MYSQL_DATABASE`, `MYSQL_USER`)
- WordPress metadata/usernames (`WP_TITLE`, `WP_ADMIN`, `WP_USER`, emails)
- domain (`DOMAIN_NAME`)

### Secrets (passwords)
Directory: `srcs/secrets/`

Passwords are stored in plain text files and mounted into containers as Docker secrets.

- `srcs/secrets/db_root_password.txt`
- `srcs/secrets/db_password.txt`
- `srcs/secrets/wp_admin_password.txt`
- `srcs/secrets/wp_user_password.txt`

Each file should contain **only** the password (no quotes, no extra lines).

## Check that services are running correctly

### Quick status
- `docker compose -p srcs -f srcs/docker-compose.yml ps`

Expected:
- `mariadb` should become **healthy** (has a healthcheck)
- `wordpress` should be running
- `nginx` should be running

### Logs
- `docker compose -p srcs -f srcs/docker-compose.yml logs -f`

Or per service:
- `docker logs -f srcs-mariadb-1`
- `docker logs -f srcs-wordpress-1`
- `docker logs -f srcs-nginx-1`

### Connectivity checks
- From host (if port is exposed): `curl -k https://<DOMAIN_NAME>/`
- Check admin page: `curl -k https://<DOMAIN_NAME>/wp-admin/`

(Use `-k` because the project typically uses a self-signed certificate.)
