use v5.42;
use utf8;

use lib 't/lib';

use HTTP::Response;
use JSON::XS;
use Test::More;

use FakeArr;
use WebService::Arr::Sonarr;

my $json = JSON::XS->new->utf8;

my $ua = FakeArr->new(
    responses => [
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"version":"4.0"}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"id":9}'),
        HTTP::Response->new(201, 'Created', [ 'Content-Type' => 'application/json' ], '{"id":101}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"records":[]}'),
    ],
);

my $sonarr = WebService::Arr::Sonarr->new(
    baseurl => 'http://sonarr.local',
    api_key => 'ABC',
    ua      => $ua,
);

my $status = $sonarr->system_status;
is($status->{version}, '4.0', 'system_status decoded');
is($ua->all_requests->[0]->method, 'GET', 'system_status uses GET');
is($ua->all_requests->[0]->uri->path, '/api/v3/system/status', 'system_status path correct');

my $series = $sonarr->series;
is(ref($series), 'ARRAY', 'series returns arrayref');
is($ua->all_requests->[1]->uri->path, '/api/v3/series', 'series path correct');

my $series_one = $sonarr->series_by_id(9);
is($series_one->{id}, 9, 'series_by_id decoded');
is($ua->all_requests->[2]->uri->path, '/api/v3/series/9', 'series_by_id path correct');

my $cmd = $sonarr->command('RescanSeries', seriesId => 9);
is($cmd->{id}, 101, 'command decoded');
is($ua->all_requests->[3]->method, 'POST', 'command uses POST');
is($ua->all_requests->[3]->uri->path, '/api/v3/command', 'command path correct');
is($json->decode($ua->all_requests->[3]->content)->{name}, 'RescanSeries', 'command payload includes name');

my $queue = $sonarr->queue(page => 1, pageSize => 20);
is(ref($queue), 'HASH', 'queue decoded');
is($ua->all_requests->[4]->uri->path, '/api/v3/queue', 'queue path correct');
like($ua->all_requests->[4]->uri->query, qr/page=1/, 'queue includes query params');
like($ua->all_requests->[4]->uri->query, qr/pageSize=20/, 'queue includes pageSize query param');

eval { $sonarr->series_by_id(q{}); 1 };
like($@, qr/series_by_id requires id/, 'series_by_id validates id');

eval { $sonarr->command(q{}); 1 };
like($@, qr/command requires name/, 'command validates name');

done_testing;