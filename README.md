# WebService::Arr

> **Work in progress.** This module is under active development. APIs are
> unstable, test coverage is incomplete, and significant churn should be
> expected.

Perl 5.42 clients for the Arr ecosystem. Thin wrappers that return decoded Perl
data structures and keep application logic out of HTTP plumbing.

Requires Perl 5.42+ (uses the `class` feature).

## Install

```text
perl Makefile.PL
make
make test
make install
```

## Services

| Class | Default port | API version | Notes |
|---|---|---|---|
| `WebService::Arr::Sonarr` | 8989 | v3 | |
| `WebService::Arr::Radarr` | 7878 | v3 | |
| `WebService::Arr::Lidarr` | 8686 | v1 | |
| `WebService::Arr::Prowlarr` | 9696 | v1 | |
| `WebService::Arr::Whisparr` | 6969 | v3 | Sonarr V3 fork |
| `WebService::Arr::Dispatcharr` | 9191 | mixed (`/api/*`) | IPTV/EPG/stream management platform |
| `WebService::Arr::Bazarr` | 6767 | `/api/*` | Subtitle management; header auth (`X-API-KEY`) |
| `WebService::Arr::Kapowarr` | 5656 | `/api/*` | Comics/manga library; query-param auth (`api_key=`) |
| `WebService::Arr::Readarr` | 8787 | v1 | retired upstream; not yet implemented |

## Quick start

```perl
use WebService::Arr::Sonarr;

my $sonarr = WebService::Arr::Sonarr->new(
    baseurl => 'http://localhost:8989',
    api_key => 'your-api-key',
);

my $status = $sonarr->system_status;
my $series = $sonarr->series;
my $show   = $sonarr->series_by_id(42);
my $queue  = $sonarr->queue(page => 1, pageSize => 20);
$sonarr->command('RescanSeries', seriesId => 42);
```

You can also use the umbrella factory module:

```perl
use WebService::Arr;

my $sonarr   = WebService::Arr::sonarr_client(baseurl => 'http://localhost:8989', api_key => '...');
my $radarr   = WebService::Arr::radarr_client(baseurl => 'http://localhost:7878', api_key => '...');
my $lidarr   = WebService::Arr::lidarr_client(baseurl => 'http://localhost:8686', api_key => '...');
my $prowlarr = WebService::Arr::prowlarr_client(baseurl => 'http://localhost:9696', api_key => '...');
my $whisparr = WebService::Arr::whisparr_client(baseurl => 'http://localhost:6969', api_key => '...');
my $dispatcharr = WebService::Arr::dispatcharr_client(baseurl => 'http://localhost:9191', api_key => '...');
my $bazarr      = WebService::Arr::bazarr_client(     baseurl => 'http://localhost:6767', api_key => '...');
my $kapowarr    = WebService::Arr::kapowarr_client(   baseurl => 'http://localhost:5656', api_key => '...', api_key_mode => 'query');
```

## Constructor options

| Option | Default | Description |
|---|---|---|
| `baseurl` | *(required)* | Base URL of the service, without trailing slash |
| `api_key` | `undef` | API key |
| `api_key_mode` | `'header'` | `'header'` (X-Api-Key) or `'query'` (?apikey=) |
| `timeout` | `30` | LWP request timeout in seconds |
| `ua` | auto | Custom `LWP::UserAgent` instance |

## Auth modes

### Header (default)

```perl
my $client = WebService::Arr::Sonarr->new(
    baseurl      => 'http://localhost:8989',
    api_key      => 'your-api-key',
    api_key_mode => 'header',
);
```

### Query string

```perl
my $client = WebService::Arr::Sonarr->new(
    baseurl      => 'http://localhost:8989',
    api_key      => 'your-api-key',
    api_key_mode => 'query',
);
```

## Endpoint coverage

### Sonarr (`WebService::Arr::Sonarr`)

```perl
$sonarr->system_status;
$sonarr->series;
$sonarr->series_by_id($id);
$sonarr->command($name, %payload);        # POST /api/v3/command
$sonarr->queue(%params);
```

### Radarr (`WebService::Arr::Radarr`)

```perl
$radarr->system_status;
$radarr->movies(%params);
$radarr->movie_by_id($id);
$radarr->command($name, %payload);        # POST /api/v3/command
$radarr->queue(%params);
$radarr->root_folders;
```

### Lidarr (`WebService::Arr::Lidarr`)

```perl
$lidarr->system_status;
$lidarr->artists(%params);
$lidarr->artist_by_id($id);
$lidarr->albums(%params);                 # supports artistId => $id
$lidarr->command($name, %payload);        # POST /api/v1/command
$lidarr->queue(%params);
```

### Prowlarr (`WebService::Arr::Prowlarr`)

```perl
$prowlarr->system_status;
$prowlarr->indexers(%params);
$prowlarr->indexer_by_id($id);
$prowlarr->search(query => 'debian', type => 'search');   # query required
$prowlarr->applications;
```

### Whisparr (`WebService::Arr::Whisparr`)

```perl
$whisparr->system_status;
$whisparr->series;
$whisparr->series_by_id($id);
$whisparr->command($name, %payload);      # POST /api/v3/command
$whisparr->queue(%params);
```

### Dispatcharr (`WebService::Arr::Dispatcharr`)

```perl
$dispatcharr->core_version;
$dispatcharr->core_environment;
$dispatcharr->system_events;
$dispatcharr->channels(%params);
$dispatcharr->channel_by_id($id);
$dispatcharr->m3u_accounts(%params);
$dispatcharr->epg_sources(%params);
```

`Dispatcharr` is not a traditional Servarr indexer/downloader API. It is a
JSON-first IPTV/EPG/stream orchestration platform. The initial Perl scaffold
intentionally targets stable JSON endpoints under `/api/*`.

For now, further Dispatcharr endpoint expansion is intentionally paused so we can
stay focused on core Arr-family priorities.

### Bazarr (`WebService::Arr::Bazarr`)

```perl
$bazarr->system_status;
$bazarr->system_health;
$bazarr->series(%params);
$bazarr->episodes(seriesid => $id);
$bazarr->movies(%params);
$bazarr->providers;
$bazarr->history(start => 0, length => 25);
$bazarr->badges;
```

Bazarr uses header auth (`X-API-KEY`), same as the Servarr applications.
Default port is `6767`.

### Kapowarr (`WebService::Arr::Kapowarr`)

```perl
$kapowarr->system_about;
$kapowarr->tasks;
$kapowarr->settings;
$kapowarr->root_folders;
$kapowarr->volumes(%params);
$kapowarr->volume_by_id($id);
$kapowarr->volumes_search(query => 'Batman');
$kapowarr->queue;
$kapowarr->history(offset => 0, limit => 25);
```

Kapowarr authenticates via an `api_key` **query parameter** (not a header).
Always pass `api_key_mode => 'query'` when constructing. Default port is `5656`.

## Candidate priorities (next)

If adding more Arr-family coverage, prioritize in this order:

1. Deepen `Bazarr` endpoint coverage.
2. Deepen `Kapowarr` endpoint coverage.
3. Improve shared operational parity across `Sonarr`, `Radarr`, `Lidarr`, and `Whisparr`.
4. Consider `Readarr` only on explicit demand (retired upstream).

## Error handling

Failed requests (non-2xx) die with a message that includes the HTTP method,
URL, status line, and the first 200 characters of the response body.

```
Carp::croak "GET http://localhost:8989/api/v3/series 401 Unauthorized\n..."
```

Wrap calls in `eval { }` or use `Try::Tiny` to catch errors.

## Design notes

See `docs/DESIGN.md` for architecture, error strategy, and versioning guidance.