use v5.42;
use utf8;

use lib 't/lib';

use HTTP::Response;
use Test::More;

use FakeArr;
use WebService::Arr::Dispatcharr;

my $ua = FakeArr->new(
    responses => [
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"version":"0.6.0"}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"debug":false}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"type":"info"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":10,"name":"News"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"id":10,"name":"News"}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":1,"name":"Provider A"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":2,"name":"Main EPG"}]'),
    ],
);

my $dispatcharr = WebService::Arr::Dispatcharr->new(
    baseurl => 'http://dispatcharr.local',
    api_key => 'DSP',
    ua      => $ua,
);

my $version = $dispatcharr->core_version;
is($version->{version}, '0.6.0', 'core_version decoded');
is($ua->all_requests->[0]->method, 'GET', 'core_version uses GET');
is($ua->all_requests->[0]->uri->path, '/api/core/version/', 'core_version path correct');

my $env = $dispatcharr->core_environment;
ok(exists $env->{debug}, 'core_environment decoded');
is($ua->all_requests->[1]->uri->path, '/api/core/settings/env/', 'core_environment path correct');

my $events = $dispatcharr->system_events;
is(ref($events), 'ARRAY', 'system_events returns arrayref');
is($ua->all_requests->[2]->uri->path, '/api/core/system-events/', 'system_events path correct');

my $channels = $dispatcharr->channels(page => 1, page_size => 50);
is(ref($channels), 'ARRAY', 'channels returns arrayref');
is($ua->all_requests->[3]->uri->path, '/api/channels/channels/', 'channels path correct');
like($ua->all_requests->[3]->uri->query, qr/page=1/, 'channels includes page query param');
like($ua->all_requests->[3]->uri->query, qr/page_size=50/, 'channels includes page_size query param');

my $channel = $dispatcharr->channel_by_id(10);
is($channel->{id}, 10, 'channel_by_id decoded');
is($ua->all_requests->[4]->uri->path, '/api/channels/channels/10/', 'channel_by_id path correct');

my $accounts = $dispatcharr->m3u_accounts(limit => 25);
is(ref($accounts), 'ARRAY', 'm3u_accounts returns arrayref');
is($ua->all_requests->[5]->uri->path, '/api/m3u/accounts/', 'm3u_accounts path correct');
like($ua->all_requests->[5]->uri->query, qr/limit=25/, 'm3u_accounts includes query param');

my $sources = $dispatcharr->epg_sources(active => 1);
is(ref($sources), 'ARRAY', 'epg_sources returns arrayref');
is($ua->all_requests->[6]->uri->path, '/api/epg/sources/', 'epg_sources path correct');
like($ua->all_requests->[6]->uri->query, qr/active=1/, 'epg_sources includes query param');

eval { $dispatcharr->channel_by_id(q{}); 1 };
like($@, qr/channel_by_id requires id/, 'channel_by_id validates id');

done_testing;