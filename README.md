# SelfDocHub — Docker image

[SelfDocHub](https://selfdochub.com) is a self-hosted portal for your API documentation. It collects OpenAPI, AsyncAPI, OpenRPC and GraphQL specifications from many services in one place and keeps their version history.

Main features:

- Multiple specification formats, services and groups, versions and branches, merge rules
- Automatic Change Log between versions
- Search and navigation across all services
- Try-It console, saved requests and environments
- Markdown overlays and text pages, export to PDF with cover pages
- Roles, teams, two-factor authentication and single sign-on (SSO)
- MCP server for AI assistants
- Notifications and audit log
- Single static binary, SQLite storage, no external database

This repository contains the Docker settings to run it on your host and the release downloads: prebuilt `docs-hub` binaries for Linux (amd64, arm64), macOS (arm64) and Windows (amd64) are attached to every [release](../../releases) with a `checksums.txt` file. The Docker image is multi-arch (`linux/amd64` and `linux/arm64`).

## Quick start

The image is published on Docker Hub: [selfdochub/selfdochub](https://hub.docker.com/r/selfdochub/selfdochub). You only need the compose file and the example settings:

```bash
mkdir selfdochub && cd selfdochub
curl -fsSLO https://raw.githubusercontent.com/SelfDocHub/self-doc-hub-image/main/docker-compose.yml
curl -fsSL https://raw.githubusercontent.com/SelfDocHub/self-doc-hub-image/main/.env.example -o .env
# edit .env: set DOCS_HUB_BASE_URL and DOCS_HUB_SESSION_SECRET (openssl rand -base64 32)

docker compose pull
docker compose up -d
docker compose logs -f docs-hub
```

The application listens on `127.0.0.1:8080`. Put a reverse proxy with TLS (Nginx, Caddy) in front of it, and set `client_max_body_size` to at least 12m.

The compose file pins a release tag.

## First run

```bash
# create the first administrator
docker compose exec docs-hub docs-hub --create-user \
  --user-login admin --user-password 'change-me' --user-role admin

# print the device ID to request a license
docker compose exec docs-hub docs-hub --print-device-id
```

Upload the resulting `license.json` on the License page. Check health: `curl http://127.0.0.1:8080/healthz`.

## Data and upgrades

All state lives in the `docs-hub-data` Docker volume (mounted at `/data`). Run exactly one container per volume.

- Back up the volume and your `.env` file (the session secret is needed to decrypt stored secrets).
- Upgrade: set `SELFDOCHUB_VERSION=<new tag>` in `.env` (tags: [Docker Hub](https://hub.docker.com/r/selfdochub/selfdochub/tags)), then `docker compose pull && docker compose up -d`. Migrations run automatically.
- Translations: the stock files (`en`, `ru`, `de`, `es`, `fr`, `pt-BR`, `zh-CN`) in `/data/translations` are refreshed automatically when the image brings new ones; the previous copies are saved to `/data/translations/backup/<timestamp>/`. Put custom edits into a file with another name (for example `it.yaml`) - such files are never touched.

Other settings are optional; see the [configuration reference](https://selfdochub.com/documentation/configuration).

## Documentation

Full documentation: <https://selfdochub.com>
