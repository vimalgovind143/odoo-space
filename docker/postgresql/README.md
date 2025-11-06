This directory is mounted at `/var/lib/postgresql/data`.
Actual PostgreSQL data files live in the subdirectory `/var/lib/postgresql/data/pgdata` (via `PGDATA`).

Note:
- Do not commit the contents of this directory to version control.
- If you see permission issues on Linux, adjust directory permissions appropriately.