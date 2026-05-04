# WebService::Arr Design Spec

> **Work in progress.** This module is under active development. APIs are
> unstable, test coverage is incomplete, and significant churn should be
> expected.


## Scope and evidence basis

This document is intentionally source-backed.

- Server-side API inventories below are derived from the application API trees in this workspace:
  - `Lidarr/src/Lidarr.Api.V1/`
  - `Sonarr/src/Sonarr.Api.V3/`
  - `Sonarr/src/Sonarr.Api.V5/`
  - `Radarr/src/Radarr.Api.V3/`
  - `Prowlarr/src/Prowlarr.Api.V1/`
  - `Whisparr/src/Whisparr.Api.V3/`
  - `Readarr/src/Readarr.Api.V1/`
  - `Dispatcharr/apps/api/`
  - `Dispatcharr/dispatcharr/urls.py`
  - `bazarr/bazarr/api/`
  - `Kapowarr/frontend/api.py`
- `pyarr` coverage is derived from:
  - `pyarr/src/pyarr/_sync/client.py`
  - `pyarr/src/pyarr/_sync/*/__init__.py`
  - `pyarr/src/pyarr/__init__.py`
- Public wiki / API-doc validation has also been checked from:
  - `https://wiki.servarr.com/`
  - `https://wiki.servarr.com/lidarr`
  - `https://wiki.servarr.com/radarr`
  - `https://wiki.servarr.com/sonarr`
  - `https://wiki.servarr.com/prowlarr`
  - `https://wiki.servarr.com/readarr`
  - `https://wiki.servarr.com/whisparr`
  - `https://lidarr.audio/docs/api/`
  - `https://radarr.video/docs/api/#/`
  - `https://sonarr.tv/docs/api`
  - `https://prowlarr.com/docs/api/#/`
  - `https://readarr.com/docs/api/`
  - `https://whisparr.com/docs/api/#/`
- The inventory is at the **top-level API resource / controller / namespace** level. It does **not** attempt to enumerate every HTTP verb/action under every controller.
- Where a repo exposes multiple API versions (notably Sonarr), the differences are called out separately.
- Where we do not have a server repo in this workspace, we distinguish between **source-verified**, **docs-verified**, and **client-only** evidence.

## Architecture and module boundaries

- `WebService::Arr::Base`
  - Owns HTTP mechanics, auth injection, JSON encoding/decoding, and error shaping.
  - Exposes generic request helpers: `get`, `post`, `put`, `delete`.
- Service modules (`WebService::Arr::Sonarr`, `::Radarr`, `::Lidarr`, `::Prowlarr`, `::Whisparr`, `::Dispatcharr`, `::Bazarr`, `::Kapowarr`, future `::Readarr`)
  - Thin endpoint wrappers only.
  - Return decoded Perl hash/array structures.
  - Own only service-specific endpoint paths and light argument validation.
- `WebService::Arr` umbrella
  - Optional constructor helpers only.
  - No transport or endpoint logic.

## Constructor/API contracts

Shared constructor contract (`Base` and subclasses):

- Required:
  - `baseurl`
- Optional:
  - `api_key`
  - `timeout` (default `30`)
  - `api_key_mode` (`header` default; also `query`)
  - `ua` (injectable test double)

Phase-1 contract already scaffolded in `Sonarr`:

- `system_status()`
- `series()`
- `series_by_id($id)`
- `command($name, %payload)`
- `queue(%params)`

## Error-handling strategy

- Non-2xx responses throw with `croak`.
- Error string includes: HTTP method, full URL, status code/text, and body snippet.
- Calling code receives decoded Perl data on success and exceptions on failure.

## Auth strategy across Arr services

- Default mode: send API key in `X-Api-Key` / `X-API-KEY` header.
- Alternate mode: query-string key (`apikey=...`) for legacy/proxy scenarios.
- Auth behavior stays centralized in `Base` so service modules remain endpoint-focused.
- Bazarr source explicitly declares API key auth in header form in `bazarr/bazarr/api/__init__.py`.

## Versioning and deprecation strategy

- Semantic-versioning style for CPAN releases.
- Phase-1 APIs are intentionally small and stable.
- Future deprecations:
  - soft-deprecate in POD/README first
  - retain compatibility where feasible
  - remove only in a major version bump

## Testing strategy

- Unit tests run fully offline.
- Fake HTTP transport verifies:
  - constructor validation
  - header/query auth behavior
  - JSON encode/decode
  - HTTP error shape
  - endpoint method/path correctness
- Future service scaffolds should keep using deterministic fake-response tests rather than live Arr instances.

## Migration approach for `balance`

1. Introduce `WebService::Arr::*` clients as dependencies.
2. Replace low-level Arr HTTP calls with client method calls.
3. Keep business logic in `balance`; move only transport/auth details out.
4. Add parity tests around adapted flows.
5. Remove duplicated HTTP helpers after parity is verified.

## Upstream wiki and public API-doc validation

These points come from the official wiki and public API-doc pages, not just local source trees.

- `Sonarr`
  - Public API docs: `https://sonarr.tv/docs/api`
  - Docs state that the **v3 API docs apply to both v3 and v4** of Sonarr.
  - Default documented server is `localhost:8989`.
- `Radarr`
  - Public API docs: `https://radarr.video/docs/api/#/`
  - Public docs are labeled **v3.0.0 OAS3**.
  - Default documented server is `localhost:7878`.
- `Lidarr`
  - Public API docs: `https://lidarr.audio/docs/api/`
  - Public docs are labeled **v1.0.0 OAS3**.
  - Default documented server is `localhost:8686`.
- `Prowlarr`
  - Public API docs: `https://prowlarr.com/docs/api/#/`
  - Public docs are labeled **v1.0.0 OAS3**.
  - Default documented server is `localhost:9696`.
- `Readarr`
  - Public API docs: `https://readarr.com/docs/api/`
  - Public docs are labeled **v1.0.0 OAS3**.
  - Default documented server is `localhost:8787`.
  - The Servarr wiki explicitly marks Readarr as **retired**.
- `Whisparr`
  - Public API docs: `https://whisparr.com/docs/api/#/`
  - Public docs are labeled **v3.0.0 OAS3**.
  - Docs state that the **v3 API docs apply to both v2 versions** of Whisparr, though some functionality may only exist in the v2 application.
  - Default documented server is `localhost:6969`.
- `Bazarr`
  - No Bazarr page was linked from the Servarr wiki root we fetched.
  - For Bazarr, this design remains **repo-source-backed**, not Servarr-wiki-backed.
  - Default port: `6767`.
- `Kapowarr`
  - Not a Servarr project. Comics/manga library manager.
  - Source-verified from `Kapowarr/frontend/api.py` in this workspace.
  - API prefix is `/api` (Flask `Blueprint`; `Constants.API_PREFIX = "/api"`).
  - Auth: `api_key` query parameter verified in source (`extract_key(request, 'api_key')`).
  - Default port: `5656` (verified in `Kapowarr/backend/internals/settings.py`).

## Cross-service namespace matrix (summary)

This table is a quick overlap view before the per-service deep dives below.

- ✅ = namespace exists as top-level in that service's source-backed inventory
- ◐ = similar capability exists but under a different top-level namespace shape
- — = not present

Service columns:

- `Sonarr`, `Radarr`, `Lidarr`, `Prowlarr`, `Whisparr`, `Readarr`, `Bazarr`, `Kapowarr`, `Dispatcharr`

| Namespace | Sonarr | Radarr | Lidarr | Prowlarr | Whisparr | Readarr | Bazarr | Kapowarr | Dispatcharr | Shared by |
|---|---|---|---|---|---|---|---|---|---|---:|
| `system` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ◐ (`core`) | 8 |
| `history` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ◐ (`activity/history`) | — | 7 |
| `health` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ◐ (`system/health`) | — | — | 6 |
| `logs` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ◐ (`system/logs`) | ◐ (`system/logs`) | — | 6 |
| `config` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — | 6 |
| `commands` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | ◐ (`system/tasks`) | — | 6 |
| `queue` | ✅ | ✅ | ✅ | — | ✅ | ✅ | — | ◐ (`activity/queue`) | — | 5 |
| `profiles` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — | 6 |
| `notifications` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ◐ (`system/notifications`) | — | — | 6 |
| `tags` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — | 6 |
| `update` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — | 6 |
| `filesystem` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — | 6 |
| `downloadclient` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — | 6 |
| `rootfolders` | ✅ | ✅ | ✅ | — | ✅ | ✅ | — | ◐ (`rootfolder`) | — | 5 |
| `indexers` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | — | 6 |
| `search` | — | — | ✅ | ✅ | — | ✅ | — | ◐ (`volumes/search`) | — | 3 |
| `series` | ✅ | — | — | — | ✅ | ✅ | ✅ | — | — | 4 |
| `movies` | — | ✅ | — | — | — | — | ✅ | — | ◐ (`vod/movies`) | 2 |
| `artist` | — | — | ✅ | — | — | — | — | — | — | 1 |
| `author` | — | — | — | — | — | ✅ | — | — | — | 1 |
| `subtitles` | — | — | — | — | — | — | ✅ | — | — | 1 |
| `providers` | — | — | — | — | — | — | ✅ | — | — | 1 |
| `volumes` | — | — | — | — | — | — | — | ✅ | — | 1 |
| `channels` | — | — | — | — | — | — | — | — | ✅ | 1 |
| `epg` | — | — | — | — | — | — | — | — | ✅ | 1 |
| `core` | — | — | — | — | — | — | — | — | ✅ | 1 |
| `vod` | — | — | — | — | — | — | — | — | ✅ | 1 |
| `backups` | — | — | — | — | — | — | — | — | ✅ | 1 |
| `plugins` | — | — | — | — | — | — | — | — | ✅ | 1 |
| `accounts` | — | — | — | — | — | — | — | — | ✅ | 1 |
| `m3u` | — | — | — | — | — | — | — | — | ✅ | 1 |
| `hdhr` | — | — | — | — | — | — | — | — | ✅ | 1 |

Quick takeaways:

- Strictly shared by all current services: **none**.
- Shared by all Servarr-family managers (`Sonarr`/`Radarr`/`Lidarr`/`Prowlarr`/`Whisparr`/`Readarr`):
  `config`, `commands`, `profiles`, `notifications`, `tags`, `update`, `filesystem`, `downloadclient`, `indexers`.
- `Bazarr`, `Kapowarr`, and `Dispatcharr` are intentionally different API families and should remain dedicated modules.

## Verified API inventory by application

### Sonarr

**Evidence**

- `Sonarr/src/Sonarr.Api.V3/`
- `Sonarr/src/Sonarr.Api.V3/openapi.json`
- `Sonarr/src/Sonarr.Api.V5/`
- `Sonarr/src/Sonarr.Api.V5/openapi.json`

**V3 top-level API groups**

- `ApplyTags`
- `AutoTagging`
- `Blocklist`
- `Calendar`
- `Commands`
- `Config`
- `CustomFilters`
- `CustomFormats`
- `DiskSpace`
- `DownloadClient`
- `EpisodeFiles`
- `Episodes`
- `FileSystem`
- `Health`
- `History`
- `ImportLists`
- `Indexers`
- `Localization`
- `Logs`
- `ManualImport`
- `MediaCovers`
- `Metadata`
- `Notifications`
- `Parse`
- `Profiles`
- `Qualities`
- `Queue`
- `RemotePathMappings`
- `RootFolders`
- `SeasonPass`
- `Series`
- `System`
- `Tags`
- `Update`
- `Wanted`

**V5 additions / differences visible in source tree**

- Present in `V5` and not in the `V3` tree listing above:
  - `Connections`
  - `Provider`
  - `Release`
  - `Settings`
- The `V5` tree also differs structurally from `V3`; for scaffolding, `V3` remains the safest initial target because that is what the current Perl MVP already uses.

### Radarr

**Evidence**

- `Radarr/src/Radarr.Api.V3/`
- `Radarr/src/Radarr.Api.V3/openapi.json`

**Top-level API groups**

- `ApplyTags`
- `AutoTagging`
- `Blocklist`
- `Calendar`
- `Collections`
- `Commands`
- `Config`
- `Credits`
- `CustomFilters`
- `CustomFormats`
- `DiskSpace`
- `DownloadClient`
- `ExtraFiles`
- `FileSystem`
- `Health`
- `History`
- `ImportLists`
- `Indexers`
- `Localization`
- `Logs`
- `ManualImport`
- `MediaCovers`
- `Metadata`
- `MovieFiles`
- `Movies`
- `Notifications`
- `Parse`
- `Profiles`
- `Qualities`
- `Queue`
- `RemotePathMappings`
- `RootFolders`
- `System`
- `Tags`
- `Update`
- `Wanted`

### Lidarr

**Evidence**

- `Lidarr/src/Lidarr.Api.V1/`
- `Lidarr/src/Lidarr.Api.V1/openapi.json`

**Top-level API groups**

- `AlbumStudio`
- `Albums`
- `ApplyTags`
- `Artist`
- `AutoTagging`
- `Blocklist`
- `Calendar`
- `Commands`
- `Config`
- `CustomFilters`
- `CustomFormats`
- `DiskSpace`
- `DownloadClient`
- `FileSystem`
- `Health`
- `History`
- `ImportLists`
- `Indexers`
- `Languages`
- `Localization`
- `Logs`
- `ManualImport`
- `MediaCovers`
- `Metadata`
- `Notifications`
- `Parse`
- `Profiles`
- `Qualities`
- `Queue`
- `RemotePathMappings`
- `RootFolders`
- `Search`
- `System`
- `Tags`
- `TrackFiles`
- `Tracks`
- `Update`
- `Wanted`

### Prowlarr

**Evidence**

- `Prowlarr/src/Prowlarr.Api.V1/`
- `Prowlarr/src/Prowlarr.Api.V1/openapi.json`

**Top-level API groups**

- `Applications`
- `Commands`
- `Config`
- `CustomFilters`
- `DownloadClient`
- `FileSystem`
- `Health`
- `History`
- `IndexerProxies`
- `Indexers`
- `Localization`
- `Logs`
- `Notifications`
- `Profiles`
- `Search`
- `System`
- `Tags`
- `Update`

### Whisparr

**Evidence**

- `Whisparr/src/Whisparr.Api.V3/` (source-verified, in workspace)
- `Whisparr/src/Whisparr.Api.V3/openapi.json`

**Top-level API groups**

- `ApplyTags`
- `AutoTagging`
- `Blocklist`
- `Calendar`
- `Commands`
- `Config`
- `CustomFilters`
- `CustomFormats`
- `DiskSpace`
- `DownloadClient`
- `EpisodeFiles`
- `Episodes`
- `FileSystem`
- `Health`
- `History`
- `ImportLists`
- `Indexers`
- `Localization`
- `Logs`
- `ManualImport`
- `MediaCovers`
- `Metadata`
- `Notifications`
- `Parse`
- `Profiles`
- `Qualities`
- `Queue`
- `RemotePathMappings`
- `RootFolders`
- `SeasonPass`
- `Series`
- `System`
- `Tags`
- `Update`
- `Wanted`

This is **identical to the Sonarr V3 top-level group set**, confirming Whisparr is a direct fork.

### Readarr

**Evidence**

- `Readarr/src/Readarr.Api.V1/` (source-verified, in workspace)
- `Readarr/src/Readarr.Api.V1/openapi.json`

**Note:** Readarr is officially marked **retired** by the Servarr project.

**Top-level API groups**

- `Author`
- `Blocklist`
- `BookFiles`
- `BookShelf`
- `Books`
- `Calendar`
- `Commands`
- `Config`
- `CustomFilters`
- `CustomFormats`
- `DiskSpace`
- `DownloadClient`
- `Editions`
- `FileSystem`
- `Health`
- `History`
- `ImportLists`
- `Indexers`
- `Languages`
- `Localization`
- `Logs`
- `ManualImport`
- `MediaCovers`
- `Metadata`
- `Notifications`
- `Parse`
- `Profiles`
- `Qualities`
- `Queue`
- `RemotePathMappings`
- `RootFolders`
- `Search`
- `Series`
- `System`
- `Tags`
- `Update`
- `Wanted`

**Readarr-specific groups** (not present in Sonarr/Radarr/Lidarr):

- `Author`
- `BookFiles`
- `BookShelf`
- `Books`
- `Editions`
- `Languages`
- `Series` (present here as a books-series concept, not TV series)

### Dispatcharr

**Evidence**

- `Dispatcharr/apps/api/urls.py`
- `Dispatcharr/dispatcharr/urls.py`
- `Dispatcharr/apps/channels/api_urls.py`
- `Dispatcharr/apps/m3u/api_urls.py`
- `Dispatcharr/apps/epg/api_urls.py`
- `Dispatcharr/core/api_urls.py`

**Top-level API namespaces mounted under `/api/`**

- `accounts`
- `channels`
- `epg`
- `hdhr`
- `m3u`
- `core`
- `plugins`
- `vod`
- `backups`
- `connect`

**Non-DRF output / compatibility endpoints from root URL config**

- Xtream-style routes: `player_api.php`, `panel_api.php`, `get.php`, `xmltv.php`
- Stream routes: `/live/<username>/<password>/<channel_id>`, `/<username>/<password>/<channel_id>`
- VOD stream routes: `/movie/...`, `/series/...`
- HDHomeRun routes under `/hdhr/*`

**Perl scaffolding scope implemented now**

- `GET /api/core/version/`
- `GET /api/core/settings/env/`
- `GET /api/core/system-events/`
- `GET /api/channels/channels/`
- `GET /api/channels/channels/:id/`
- `GET /api/m3u/accounts/`
- `GET /api/epg/sources/`

This is intentionally a JSON-first subset. Output and compatibility endpoints
that return non-JSON payloads (M3U, XMLTV, proxied media streams) are out of
scope for the initial Perl wrapper.

### Bazarr

**Evidence**

- `bazarr/bazarr/api/__init__.py`
- `bazarr/bazarr/api/swaggerui.py`
- namespace packages under `bazarr/bazarr/api/`

**Top-level API namespaces registered in source**

- `badges`
- `episodes`
- `files`
- `history`
- `movies`
- `providers`
- `series`
- `subtitles`
- `system`
- `webhooks`
- `plex`

**Notable nested namespaces visible in source files**

- `episodes/*`
  - `episodes.py`
  - `episodes_subtitles.py`
  - `history.py`
  - `blacklist.py`
  - `wanted.py`
- `movies/*`
  - `movies.py`
  - `movies_subtitles.py`
  - `history.py`
  - `blacklist.py`
  - `wanted.py`
- `system/*`
  - `account.py`
  - `announcements.py`
  - `backups.py`
  - `health.py`
  - `jobs.py`
  - `languages.py`
  - `languages_profiles.py`
  - `logs.py`
  - `notifications.py`
  - `ping.py`
  - `releases.py`
  - `searches.py`
  - `settings.py`
  - `status.py`
  - `system.py`
  - `tasks.py`
- `files/*`
  - `files.py`
  - `files_radarr.py`
  - `files_sonarr.py`
- `providers/*`
  - `providers.py`
  - `providers_movies.py`
  - `providers_episodes.py`
- `webhooks/*`
  - `plex.py`
  - `radarr.py`
  - `sonarr.py`

### Kapowarr

**Evidence**

- `Kapowarr/frontend/api.py` (source-verified, in workspace)
- `Kapowarr/backend/base/definitions.py` (`API_PREFIX = "/api"`)
- `Kapowarr/backend/internals/settings.py` (default port `5656`, auth via `api_key` param)

**Top-level API route groups**

- `auth`
- `public`
- `system` (`/system/about`, `/system/logs`, `/system/tasks`, `/system/tasks/history`, `/system/tasks/planning`, `/system/power/shutdown`, `/system/power/restart`)
- `settings` (`/settings`, `/settings/api_key`, `/settings/availableformats`)
- `rootfolder` (`/rootfolder`, `/rootfolder/:id`)
- `remotemapping` (`/remotemapping`, `/remotemapping/:id`)
- `libraryimport`
- `volumes` (`/volumes`, `/volumes/search`, `/volumes/stats`, `/volumes/:id`, `/volumes/:id/cover`, `/volumes/:id/manualmatch`, `/volumes/:id/rename`, `/volumes/:id/convert`, `/volumes/:id/manualsearch`, `/volumes/:id/download`)
- `issues` (`/issues/:id`, `/issues/:id/rename`, `/issues/:id/convert`, `/issues/:id/manualsearch`, `/issues/:id/download`)
- `activity` (`/activity/queue`, `/activity/history`, `/activity/folder`)
- `blocklist` (`/blocklist`, `/blocklist/:id`)
- `credentials` (`/credentials`, `/credentials/:id`)
- `externalclients` (`/externalclients`, `/externalclients/options`, `/externalclients/test`, `/externalclients/:id`)
- `masseditor`
- `files` (`/files/:id`)

**Auth note**

Kapowarr authenticates via an `api_key` query parameter, not the `X-Api-Key` header style used by the Servarr services. The initial Perl scaffold should use `api_key_mode => 'query'` by default, or document this explicitly in the POD.

**Perl scaffolding scope implemented now**

- `GET /api/system/about` — `system_about()`
- `GET /api/system/tasks` — `tasks(%params)`
- `GET /api/volumes` — `volumes(%params)`
- `GET /api/volumes/search` — `volumes_search(query => $q, %params)`
- `GET /api/volumes/:id` — `volume_by_id($id)`
- `GET /api/rootfolder` — `root_folders()`
- `GET /api/activity/queue` — `queue(%params)`
- `GET /api/activity/history` — `history(%params)`
- `GET /api/settings` — `settings()`

### pyarr (Python client)

**Evidence**

- `pyarr/src/pyarr/__init__.py`
- `pyarr/src/pyarr/_sync/client.py`
- `pyarr/src/pyarr/_sync/sonarr/__init__.py`
- `pyarr/src/pyarr/_sync/radarr/__init__.py`
- `pyarr/src/pyarr/_sync/lidarr/__init__.py`
- `pyarr/src/pyarr/_sync/prowlarr/__init__.py`
- `pyarr/src/pyarr/_sync/bazarr/__init__.py`
- `pyarr/src/pyarr/_sync/readarr/__init__.py`
- `pyarr/src/pyarr/_sync/whisparr/__init__.py`

**Exported service clients**

- `Sonarr`
- `Radarr`
- `Readarr`
- `Lidarr`
- `Prowlarr`
- `Bazarr`
- `Whisparr`
- `Dispatcharr`
- async equivalents for each of the above

**Common client surface attached by `BaseArrClient`**

- `backup`
- `blocklist`
- `calendar`
- `command`
- `download_client`
- `history`
- `import_list`
- `indexer`
- `log`
- `metadata`
- `notification`
- `quality_definition`
- `quality_profile`
- `queue`
- `remote_path_mapping`
- `root_folder`
- `system`
- `tag`
- `update`

**Service-specific client surfaces**

- `Sonarr`
  - `config`, `series`, `episode`, `episode_file`, `release`, `manual_import`, `wanted`
- `Radarr`
  - `config`, `movie`, `movie_file`, `release`, `manual_import`, `custom_filter`, `wanted`
- `Lidarr`
  - `config`, `artist`, `album`, `track`, `track_file`, `release`, `manual_import`, `wanted`
- `Prowlarr`
  - `indexer`, `search`, `applications`, `indexer_proxy`
- `Bazarr`
  - `subtitles`, `providers`, `wanted` (bound to `subtitles/wanted`)
- `Readarr`
  - `config`, `author`, `book`, `edition`, `metadata_profile`, `release_profile`, `delay_profile`, `manual_import`, `wanted`
- `Whisparr`
  - `config`, `movie`, `movie_file`, `release`, `manual_import`, `custom_filter`, `wanted`

## Intersection and divergence

### Exact top-level overlap across Lidarr, Sonarr V3, Radarr, and Prowlarr

These names are present as top-level API groups in all four source trees:

- `Commands`
- `Config`
- `CustomFilters`
- `DownloadClient`
- `FileSystem`
- `Health`
- `History`
- `Indexers`
- `Localization`
- `Logs`
- `Notifications`
- `Profiles`
- `System`
- `Tags`
- `Update`

This is the strongest shared surface for initial cross-service scaffolding.

### Exact top-level overlap across the media-manager trio: Lidarr, Sonarr V3, Radarr

These names are present in all three trees:

- `ApplyTags`
- `AutoTagging`
- `Blocklist`
- `Calendar`
- `Commands`
- `Config`
- `CustomFilters`
- `CustomFormats`
- `DiskSpace`
- `DownloadClient`
- `FileSystem`
- `Health`
- `History`
- `ImportLists`
- `Indexers`
- `Localization`
- `Logs`
- `ManualImport`
- `MediaCovers`
- `Metadata`
- `Notifications`
- `Parse`
- `Profiles`
- `Qualities`
- `Queue`
- `RemotePathMappings`
- `RootFolders`
- `System`
- `Tags`
- `Update`
- `Wanted`

This is the clearest common contract family for `Sonarr`, `Radarr`, and `Lidarr`.

### Whisparr overlap with Sonarr V3

Whisparr shares **every top-level API group** from Sonarr V3. The source tree is an exact fork. The current Perl implementation reuses the same method set.

### Readarr overlap

Readarr shares the broad operational surface (`Commands`, `Config`, `Queue`, `System`, `Health`, `History`, etc.) but diverges with book-oriented resource groups (`Author`, `Books`, `BookFiles`, `BookShelf`, `Editions`) in place of the series/episode or movie/artist families. Its `Series` group refers to book series, not TV series.

### Media-manager divergence: exact per-service groups

**Lidarr-only groups from the verified tree**

- `AlbumStudio`
- `Albums`
- `Artist`
- `Languages`
- `Search`
- `TrackFiles`
- `Tracks`

**Sonarr-only groups from the verified V3 tree**

- `EpisodeFiles`
- `Episodes`
- `SeasonPass`
- `Series`

**Radarr-only groups from the verified tree**

- `Collections`
- `Credits`
- `ExtraFiles`
- `MovieFiles`
- `Movies`

### Prowlarr divergence

Prowlarr shares the operational/control surface above, but its unique top-level groups are:

- `Applications`
- `IndexerProxies`
- `Search`

This makes it closer to an indexer/application-integration service than to the media-library managers.

### Bazarr divergence

Bazarr does **not** mirror the same controller layout as the .NET Arr apps.

- Its top-level namespaces are subtitle-oriented and integration-oriented:
  - `subtitles`, `providers`, `webhooks`, `plex`
- Shared concerns such as health, logs, notifications, backups, and settings are nested under `system/*` rather than exposed as peer top-level groups.
- It also splits media-specific concerns under `episodes/*`, `movies/*`, and `series/*`.

### Exact overlap including Bazarr

At the **exact top-level namespace** level, Bazarr aligns poorly with the controller naming used by Sonarr/Radarr/Lidarr/Prowlarr.

The only obvious case-insensitive top-level overlap visible directly from source tree names is:

- `history`
- `system`

That does **not** mean Bazarr lacks the other operational concerns; it means Bazarr organizes them under nested namespaces instead of the flatter controller layout used by the .NET Arr apps.

### What `pyarr` tells us

`pyarr` is useful as a client-shape reference, but it is **not** proof that every server exposes the exact same surface.

What it does prove:

- there is practical value in a shared base client
- the ecosystem is broad enough to justify service-specific classes
- common operational resources are worth normalizing when they genuinely exist

What it does **not** prove by itself:

- that every service has identical endpoints
- that a shared Perl abstraction should be broader than the verified overlap above

### Readarr and Whisparr evidence status

- `Readarr`
  - now has **source-verified** evidence from `Readarr/src/Readarr.Api.V1/` in this workspace
  - the Servarr wiki explicitly marks Readarr as **retired**, which lowers implementation priority
  - a Perl module (`WebService::Arr::Readarr`) is a future candidate but not yet scaffolded
- `Whisparr`
  - now has **source-verified** evidence from `Whisparr/src/Whisparr.Api.V3/` in this workspace
  - the source tree confirms it is a near-identical Sonarr V3 fork at the API level
  - `WebService::Arr::Whisparr` is fully implemented
- `Dispatcharr`
  - now has **source-verified** evidence from `Dispatcharr/apps/api/` and `Dispatcharr/dispatcharr/urls.py`
  - differs from Servarr shape: mixes DRF JSON API namespaces with compatibility/output routes
  - `WebService::Arr::Dispatcharr` is scaffolded with a JSON-first subset
- `Bazarr`
  - now has **source-verified** evidence from `bazarr/bazarr/api/` in this workspace
  - structurally different from the .NET Arr apps; subtitle/provider/system namespace model
  - `WebService::Arr::Bazarr` is scaffolded with system, series, episodes, movies, and providers endpoints
- `Kapowarr`
  - now has **source-verified** evidence from `Kapowarr/frontend/api.py` in this workspace
  - comics/manga library manager; Flask/Blueprint API under `/api`
  - uses `api_key` query-param auth (not header auth)
  - `WebService::Arr::Kapowarr` is scaffolded with system, volumes, activity, rootfolder, and settings endpoints

## Architectural implications for Perl scaffolding

The verified source trees point to five implementation families:

1. **Media-manager family**: `Sonarr`, `Radarr`, `Lidarr`
   - Highest overlap.
   - Best candidates for consistent early scaffolding after the shared `Base` transport layer.
2. **Sonarr fork**: `Whisparr`
   - Source-verified as an identical API fork of Sonarr V3.
   - Fully implemented: `WebService::Arr::Whisparr`.
3. **Indexer/integration family**: `Prowlarr`
   - Shares operational endpoints but diverges into `Applications`, `IndexerProxies`, and `Search`.
   - Should be its own service module, not treated as a media-library clone.
4. **Subtitle/integration family**: `Bazarr`
   - Structurally different namespace model.
   - `WebService::Arr::Bazarr` is scaffolded with a JSON-first subset.
5. **Comics/manga library**: `Kapowarr`
   - Not a Servarr project; shares the `Base` transport pattern but uses query-param auth.
   - `WebService::Arr::Kapowarr` is scaffolded with core library and activity endpoints.
6. **IPTV orchestration family**: `Dispatcharr`
  - Django/DRF API plus compatibility/output endpoints (Xtream/HDHR/proxy stream routes).
  - Not a drop-in Servarr clone; should remain a dedicated service module.

Readarr follows the same broad operational pattern as the media-manager family but has a distinct book-oriented resource model. It is retired upstream and is a low-priority candidate for Perl scaffolding.

This argues for:

- keeping `WebService::Arr::Base` as the only shared transport/auth layer
- keeping service modules thin and explicit
- avoiding a second abstract superclass until real duplication appears in Perl code
- using the verified shared groups above to prioritize initial endpoint scaffolding

## Scaffolding roadmap

- **Phase 1:** ship stable transport/auth base and one proven service (`Sonarr`) — **complete**.
- **Phase 2:** add thin service shells for `Radarr`, `Lidarr`, `Prowlarr`, and `Whisparr`, with a small set of verified high-value endpoints per service — **complete**.
- **Phase 3:** scaffold `Dispatcharr` with JSON-first endpoints under `/api/*` — **complete**.
- **Phase 4:** scaffold `WebService::Arr::Bazarr` (subtitle management) and `WebService::Arr::Kapowarr` (comics/manga) — **complete**.
- **Phase 5:** grow common operational endpoints where overlap is source-verified (`system`, `history`, `command`, `queue`, `root folders`, etc. for the media-manager family).
- **Phase 6:** add service-specific families (`Prowlarr::Applications`, deeper `Bazarr::Subtitles`) after the shared operational layer is stable.
- **Phase 7 (optional):** `WebService::Arr::Readarr` — low priority due to upstream retirement.

### Near-term candidate focus (non-Dispatcharr)

To stay focused, we are **not** expanding Dispatcharr coverage right now beyond the
current JSON-first subset.

Current priority order for additional Arr-family work:

1. Deepen `Bazarr` coverage (subtitle lifecycle: wanted/blacklist/history/subtitles).
2. Deepen `Kapowarr` coverage (library/workflow endpoints around volumes/issues/activity).
3. Expand shared operational parity across media managers (`Sonarr`/`Radarr`/`Lidarr`/`Whisparr`).
4. Revisit optional `Readarr` support only if there is a concrete user need.

## Assumptions kept intentionally narrow

- We are documenting only what is visible in the checked-out source trees and client modules.
- We are not claiming full endpoint parity across services.
- For Whisparr, local source evidence now confirms it is a Sonarr V3 fork at the API level.
- For Readarr, local source evidence now confirms its book-oriented resource model; it remains deprioritized due to upstream retirement.
- For Dispatcharr, local source evidence confirms a mixed API shape; initial Perl coverage is intentionally JSON-only and intentionally frozen for now.