# Odoo + PostgreSQL via Docker Compose

This setup mirrors the style of the `odoo-19-docker-compose` project while adapting it to this repository.

## Quick start

1. Ensure Docker Desktop is installed and running.
2. From the repo root, start services:
   - `docker compose up -d`
3. Open Odoo at `http://localhost:10019`.
   - Longpolling (live chat) is exposed at `http://localhost:20019/longpolling/`.

## Configuration

All key settings are in `.env`:
- `ODOO_IMAGE` (default `odoo:19`)
- `POSTGRES_VERSION` (default `17` for latest stable)
- `ODOO_HTTP_PORT` (default `10019`)
- `ODOO_LONGPOLLING_PORT` (default `20019`)
- `POSTGRES_HOST_PORT` (default `54320`)
- `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
- `ODOO_ADMIN_PASSWD` (database manager password)

Odoo runtime config is in `docker/etc/odoo.conf`. The database connection and addons path are preset to work with this compose setup. The admin (database manager) password is passed via the container command for convenience.

## Custom addons

Place your custom modules in `docker/addons/`. These are mounted to `/mnt/extra-addons` in the Odoo container and included in `addons_path`.

To avoid duplication, do not put core Odoo addons here; the image already includes them.

## Postgres data

Data files are stored in `docker/postgresql/` on the host and mounted via `PGDATA`.

## Service management

- Start: `docker compose up -d`
- Stop: `docker compose down`
- Restart Odoo: `docker compose restart odoo`
- View logs: `docker compose logs -f odoo`

## pgAdmin (DB management)

- Access pgAdmin: `http://localhost:5050`
- Login with credentials from `.env`:
  - `PGADMIN_DEFAULT_EMAIL`
  - `PGADMIN_DEFAULT_PASSWORD`
- A server named "Odoo DB" is pre-registered, pointing to the `db` service.
  - Host: `db`
  - Port: `5432`
  - Username: `odoo`
  - Maintenance DB: `postgres`
  - Enter the database password from `.env` (`POSTGRES_PASSWORD`) on first connect.

## Live chat reverse proxy (optional)

If you use a reverse proxy (e.g., Nginx), proxy the longpolling endpoint:

```
location /longpolling/ {
    proxy_pass http://127.0.0.1:20019/longpolling/;
}
```

## Notes

- The compose file includes a DB healthcheck so Odoo waits for Postgres.
- On Linux, you may need to adjust permissions for `docker/postgresql/` and `docker/addons/`.
- For production, tune workers and memory limits in `docker/etc/odoo.conf`.