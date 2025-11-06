# Odoo Docker Technical Notes

This document captures key technical decisions, package choices, and troubleshooting notes from setting up this repository to run Odoo from local sources under Docker, with PostgreSQL and pgAdmin.

## Base Images & Runtime

- Python runtime: `python:3.12-slim`
- Reason: matches `requirements.txt` pins (e.g., `gevent` ≥ 24.x), avoids Cython build failures seen on Python 3.10.
- Odoo runs from your local repo via `python odoo-bin` with source mounted at `/workspace`.

## System Packages

Installed via apt to support Odoo build/runtime:
- Build and core libs: `build-essential`, `libpq-dev`, `libxml2-dev`, `libxslt1-dev`, `libffi-dev`, `libssl-dev`, `pkg-config`
- Imaging: `libjpeg-dev`, `zlib1g-dev`, `libfreetype6-dev`, `liblcms2-dev`, `libwebp-dev`, `libharfbuzz-dev`, `libfribidi-dev`
- LDAP: `libldap2-dev`, `libsasl2-dev`
- Node tooling: `nodejs`, `npm`

## Python Dependencies

- Installed from repository `requirements.txt`.
- Notable pins compatible with Python 3.12:
  - `gevent==24.2.1` and `greenlet==3.0.3` (Linux)
  - `lxml==5.2.1`
  - `Pillow==10.2.0`
- Avoided Python 3.10 due to `gevent` cython compile error (undeclared name: `long`).

## PostgreSQL Setup

- Image: `postgres:${POSTGRES_VERSION}` (default `17`).
- Volume: host `./docker/postgresql` → container `/var/lib/postgresql/data`.
- `PGDATA` set to `/var/lib/postgresql/data/pgdata` so non-empty mount root (e.g., README) does not block initialization.
- Healthcheck tuned: `pg_isready -U ${POSTGRES_USER} -h localhost -p 5432` with `start_period` and extra `retries` for first boot.

## Odoo Configuration

- Config file: `docker/etc/odoo.conf`
- `addons_path = /workspace/odoo/addons,/mnt/extra-addons` (local sources + custom addons mount).
- `admin_passwd` set in config; CLI flag `--admin-passwd` removed (deprecated/invalid).
- Default dev mode: `workers = 0` for single-threaded local development.
- Ports: `8069` mapped to host `10019`, longpolling `8072` mapped to host `20019`.
- Notes: Odoo 19 may log warnings for legacy options (`xmlrpc`, `longpolling_port`); they are harmless.

## wkhtmltopdf / wkhtmltoimage

- Debian trixie/bookworm apt no longer provides `wkhtmltopdf`; installed from upstream packaging release.
- Package: `wkhtmltox_0.12.6.1-3.bookworm_amd64.deb` ([GitHub packaging releases]).
- Additional fonts/X libs installed to satisfy runtime:
  - `fontconfig`, `fonts-dejavu-core`, `xfonts-base`, `xfonts-75dpi`, `libxrender1`, `libxext6`, `libx11-6`, `libpng16-16`, etc.
- Verified in container: `wkhtmltopdf --version` → `0.12.6.1 (with patched qt)`.

## pgAdmin

- Image: `dpage/pgadmin4:latest` with persistent storage in `docker/pgadmin`.
- Pre-registered server file: `docker/pgadmin/servers.json` (points to `db` service).
- Credentials via `.env`: `PGADMIN_DEFAULT_EMAIL`, `PGADMIN_DEFAULT_PASSWORD`.
- Host access: `http://localhost:5050`.

## Compose & Environment

- Compose updates:
  - `odoo` builds from local `Dockerfile`, mounts repo as `/workspace`, uses `odoo.conf`.
  - Removed obsolete `version` key.
  - DB healthcheck and PGDATA adjustments.
- `.env` variables:
  - Versions/ports: `POSTGRES_VERSION`, `ODOO_HTTP_PORT`, `ODOO_LONGPOLLING_PORT`, `POSTGRES_HOST_PORT`.
  - DB creds: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`.
  - Admin password: `ODOO_ADMIN_PASSWD` (set in `odoo.conf`).

## Common Issues & Fixes

- DB unhealthy / init errors:
  - Cause: non-empty data dir. Fix: use `PGDATA` subdir and clear `docker/postgresql/pgdata` if re-initializing.
- Odoo not starting with `--admin-passwd`:
  - Cause: flag unsupported. Fix: set `admin_passwd` in `odoo.conf`.
- PDF/image report errors:
  - Cause: missing wkhtmltopdf/wkhtmltoimage. Fix: install via packaging .deb and fonts/X libs.
- Windows host:
  - Ensure Docker Desktop file sharing includes your repo path for volume mounts.

## Verification Commands

- Build: `docker compose build`
- Start: `docker compose up -d`
- Logs: `docker compose logs -f odoo`
- pgAdmin: `http://localhost:5050`
- wkhtmltopdf: `docker compose exec odoo wkhtmltopdf --version`

## References

- wkhtmltopdf Packaging Releases: https://github.com/wkhtmltopdf/packaging/releases
- Debian Archive (apt repos): http://deb.debian.org/debian
- Debian Security: http://deb.debian.org/debian-security

[GitHub packaging releases]: https://github.com/wkhtmltopdf/packaging/releases