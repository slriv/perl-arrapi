use v5.42;
use utf8;

use lib 't/lib';

use HTTP::Response;
use Test::More;

use FakeArr;
use WebService::Arr::Prowlarr;

my $ua = FakeArr->new(
    responses => [
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"version":"1.0"}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":3,"name":"NZBgeek"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"id":3,"name":"NZBgeek"}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"title":"result"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":1}]'),
    ],
);

my $prowlarr = WebService::Arr::Prowlarr->new(
    baseurl => 'http://prowlarr.local',
    api_key => 'PRW',
    ua      => $ua,
);

my $status = $prowlarr->system_status;
is($status->{version}, '1.0', 'system_status decoded');
is($ua->all_requests->[0]->method, 'GET', 'system_status uses GET');
is($ua->all_requests->[0]->uri->path, '/api/v1/system/status', 'system_status path correct');

my $indexers = $prowlarr->indexers;
is(ref($indexers), 'ARRAY', 'indexers returns arrayref');
is($ua->all_requests->[1]->uri->path, '/api/v1/indexer', 'indexers path correct');

my $indexer = $prowlarr->indexer_by_id(3);
is($indexer->{name}, 'NZBgeek', 'indexer_by_id decoded');
is($ua->all_requests->[2]->uri->path, '/api/v1/indexer/3', 'indexer_by_id path correct');

my $results = $prowlarr->search(query => 'debian');
is(ref($results), 'ARRAY', 'search returns arrayref');
is($ua->all_requests->[3]->uri->path, '/api/v1/search', 'search path correct');
like($ua->all_requests->[3]->uri->query, qr/query=debian/, 'search passes query param');

my $apps = $prowlarr->applications;
is(ref($apps), 'ARRAY', 'applications returns arrayref');
is($ua->all_requests->[4]->uri->path, '/api/v1/applications', 'applications path correct');

eval { $prowlarr->indexer_by_id(q{}); 1 };
like($@, qr/indexer_by_id requires id/, 'indexer_by_id validates id');

eval { $prowlarr->search(type => 'search'); 1 };
like($@, qr/search requires query/, 'search validates query param');

done_testing;
