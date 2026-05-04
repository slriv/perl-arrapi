use v5.42;
use utf8;

use lib 't/lib';

use HTTP::Response;
use Test::More;

use FakeArr;
use WebService::Arr::Kapowarr;

my $ua = FakeArr->new(
    responses => [
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"version":"2.1.0","platform":"linux"}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":1,"name":"Update library"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"comicvine_api_key":"cv123"}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":1,"folder":"/comics"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":10,"title":"Batman"},{"id":11,"title":"Superman"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"id":10,"title":"Batman","issue_count":42}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":5,"title":"Batman: Year One"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":1,"status":"downloading"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":99,"title":"Batman #1","status":"success"}]'),
    ],
);

my $kapowarr = WebService::Arr::Kapowarr->new(
    baseurl      => 'http://kapowarr.local:5656',
    api_key      => 'KAP',
    api_key_mode => 'query',
    ua           => $ua,
);

my $about = $kapowarr->system_about;
is($about->{version}, '2.1.0', 'system_about decoded');
is($ua->all_requests->[0]->method, 'GET', 'system_about uses GET');
is($ua->all_requests->[0]->uri->path, '/api/system/about', 'system_about path correct');
like($ua->all_requests->[0]->uri->query, qr/apikey=KAP/, 'system_about sends api_key as query param');

my $tasks = $kapowarr->tasks;
is(ref($tasks), 'ARRAY', 'tasks returns arrayref');
is($ua->all_requests->[1]->uri->path, '/api/system/tasks', 'tasks path correct');

my $settings = $kapowarr->settings;
ok(exists $settings->{comicvine_api_key}, 'settings decoded');
is($ua->all_requests->[2]->uri->path, '/api/settings', 'settings path correct');

my $folders = $kapowarr->root_folders;
is(ref($folders), 'ARRAY', 'root_folders returns arrayref');
is($ua->all_requests->[3]->uri->path, '/api/rootfolder', 'root_folders path correct');

my $volumes = $kapowarr->volumes(offset => 0, limit => 50);
is(ref($volumes), 'ARRAY', 'volumes returns arrayref');
is(scalar @{$volumes}, 2, 'volumes returns expected count');
is($ua->all_requests->[4]->uri->path, '/api/volumes', 'volumes path correct');
like($ua->all_requests->[4]->uri->query, qr/limit=50/, 'volumes includes limit query param');

my $vol = $kapowarr->volume_by_id(10);
is($vol->{id}, 10, 'volume_by_id decoded');
is($vol->{issue_count}, 42, 'volume_by_id has issue_count');
is($ua->all_requests->[5]->uri->path, '/api/volumes/10', 'volume_by_id path correct');

my $results = $kapowarr->volumes_search(query => 'Batman');
is(ref($results), 'ARRAY', 'volumes_search returns arrayref');
is($ua->all_requests->[6]->uri->path, '/api/volumes/search', 'volumes_search path correct');
like($ua->all_requests->[6]->uri->query, qr/query=Batman/, 'volumes_search includes query param');

my $queue = $kapowarr->queue;
is(ref($queue), 'ARRAY', 'queue returns arrayref');
is($ua->all_requests->[7]->uri->path, '/api/activity/queue', 'queue path correct');

my $history = $kapowarr->history(offset => 0, limit => 25);
is(ref($history), 'ARRAY', 'history returns arrayref');
is($ua->all_requests->[8]->uri->path, '/api/activity/history', 'history path correct');
like($ua->all_requests->[8]->uri->query, qr/limit=25/, 'history includes limit query param');

eval { $kapowarr->volume_by_id(q{}); 1 };
like($@, qr/volume_by_id requires id/, 'volume_by_id validates id');

eval { $kapowarr->volumes_search(query => q{}); 1 };
like($@, qr/volumes_search requires query/, 'volumes_search validates query');

done_testing;
