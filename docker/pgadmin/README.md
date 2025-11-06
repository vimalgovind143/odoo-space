pgAdmin data directory for the Docker container.

- Container data persists here: `/var/lib/pgadmin`.
- Pre-registered servers are defined in `servers.json` and mounted to `/pgadmin4/servers.json`.
- Default login credentials come from `.env` (`PGADMIN_DEFAULT_EMAIL` / `PGADMIN_DEFAULT_PASSWORD`).