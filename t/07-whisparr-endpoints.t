use v5.42;
use utf8;

use lib 't/lib';

use HTTP::Response;
use JSON::XS;
use Test::More;

use FakeArr;
use WebService::Arr::Whisparr;

my $json = JSON::XS->new->utf8;

my $ua = FakeArr->new(
    responses => [
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"version":"3.0"}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"id":5}'),
        HTTP::Response->new(201, 'Created', [ 'Content-Type' => 'application/json' ], '{"id":404}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"records":[]}'),
    ],
);

my $whisparr = WebService::Arr::Whisparr->new(
    baseurl => 'http://whisparr.local',
    api_key => 'WHI',
    ua      => $ua,
);

my $status = $whisparr->system_status;
is($status->{version}, '3.0', 'system_status decoded');
is($ua->all_requests->[0]->method, 'GET', 'system_status uses GET');
is($ua->all_requests->[0]->uri->path, '/api/v3/system/status', 'system_status path correct');

my $series = $whisparr->series;
is(ref($series), 'ARRAY', 'series returns arrayref');
is($ua->all_requests->[1]->uri->path, '/api/v3/series', 'series path correct');

my $one = $whisparr->series_by_id(5);
is($one->{id}, 5, 'series_by_id decoded');
is($ua->all_requests->[2]->uri->path, '/api/v3/series/5', 'series_by_id path correct');

my $cmd = $whisparr->command('RescanSeries', seriesId => 5);
is($cmd->{id}, 404, 'command decoded');
is($ua->all_requests->[3]->method, 'POST', 'command uses POST');
is($ua->all_requests->[3]->uri->path, '/api/v3/command', 'command path correct');
is($json->decode($ua->all_requests->[3]->content)->{name}, 'RescanSeries', 'command payload includes name');

my $queue = $whisparr->queue(page => 2);
is(ref($queue), 'HASH', 'queue decoded');
is($ua->all_requests->[4]->uri->path, '/api/v3/queue', 'queue path correct');
like($ua->all_requests->[4]->uri->query, qr/page=2/, 'queue includes page param');

eval { $whisparr->series_by_id(q{}); 1 };
like($@, qr/series_by_id requires id/, 'series_by_id validates id');

eval { $whisparr->command(q{}); 1 };
like($@, qr/command requires name/, 'command validates name');

done_testing;
