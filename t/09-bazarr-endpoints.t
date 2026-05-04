use v5.42;
use utf8;

use lib 't/lib';

use HTTP::Response;
use Test::More;

use FakeArr;
use WebService::Arr::Bazarr;

my $ua = FakeArr->new(
    responses => [
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"bazarr_version":"1.4.0","python_version":"3.11"}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"issue":"OK"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"sonarrSeriesId":1,"title":"Breaking Bad"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"sonarrEpisodeId":101,"title":"Pilot"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"radarrId":20,"title":"Inception"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"name":"OpenSubtitles","enabled":true}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":1,"action":"Download"}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"episodes":3,"movies":1}'),
    ],
);

my $bazarr = WebService::Arr::Bazarr->new(
    baseurl => 'http://bazarr.local:6767',
    api_key => 'BAZ',
    ua      => $ua,
);

my $status = $bazarr->system_status;
is($status->{bazarr_version}, '1.4.0', 'system_status decoded');
is($ua->all_requests->[0]->method, 'GET', 'system_status uses GET');
is($ua->all_requests->[0]->uri->path, '/api/system/status', 'system_status path correct');
like($ua->all_requests->[0]->header('X-Api-Key') // $ua->all_requests->[0]->header('X-API-KEY') // '',
     qr/BAZ/, 'system_status sends api key header');

my $health = $bazarr->system_health;
is(ref($health), 'ARRAY', 'system_health returns arrayref');
is($ua->all_requests->[1]->uri->path, '/api/system/health', 'system_health path correct');

my $series = $bazarr->series;
is(ref($series), 'ARRAY', 'series returns arrayref');
is($ua->all_requests->[2]->uri->path, '/api/series', 'series path correct');

my $episodes = $bazarr->episodes(seriesid => 1);
is(ref($episodes), 'ARRAY', 'episodes returns arrayref');
is($ua->all_requests->[3]->uri->path, '/api/episodes', 'episodes path correct');
like($ua->all_requests->[3]->uri->query, qr/seriesid=1/, 'episodes includes seriesid query param');

my $movies = $bazarr->movies(start => 0, length => 10);
is(ref($movies), 'ARRAY', 'movies returns arrayref');
is($ua->all_requests->[4]->uri->path, '/api/movies', 'movies path correct');
like($ua->all_requests->[4]->uri->query, qr/length=10/, 'movies includes length query param');

my $providers = $bazarr->providers;
is(ref($providers), 'ARRAY', 'providers returns arrayref');
is($ua->all_requests->[5]->uri->path, '/api/providers', 'providers path correct');

my $history = $bazarr->history(start => 0, length => 25);
is(ref($history), 'ARRAY', 'history returns arrayref');
is($ua->all_requests->[6]->uri->path, '/api/history', 'history path correct');
like($ua->all_requests->[6]->uri->query, qr/length=25/, 'history includes length query param');

my $badges = $bazarr->badges;
ok(exists $badges->{episodes}, 'badges decoded');
is($ua->all_requests->[7]->uri->path, '/api/badges', 'badges path correct');

done_testing;
