use v5.42;
use utf8;

use lib 't/lib';

use HTTP::Response;
use JSON::XS;
use Test::More;

use FakeArr;
use WebService::Arr::Radarr;

my $json = JSON::XS->new->utf8;

my $ua = FakeArr->new(
    responses => [
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"version":"5.0"}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"id":7}'),
        HTTP::Response->new(201, 'Created', [ 'Content-Type' => 'application/json' ], '{"id":202}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"records":[]}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"path":"/movies"}]'),
    ],
);

my $radarr = WebService::Arr::Radarr->new(
    baseurl => 'http://radarr.local',
    api_key => 'XYZ',
    ua      => $ua,
);

my $status = $radarr->system_status;
is($status->{version}, '5.0', 'system_status decoded');
is($ua->all_requests->[0]->method, 'GET', 'system_status uses GET');
is($ua->all_requests->[0]->uri->path, '/api/v3/system/status', 'system_status path correct');

my $movies = $radarr->movies;
is(ref($movies), 'ARRAY', 'movies returns arrayref');
is($ua->all_requests->[1]->uri->path, '/api/v3/movie', 'movies path correct');

my $movie = $radarr->movie_by_id(7);
is($movie->{id}, 7, 'movie_by_id decoded');
is($ua->all_requests->[2]->uri->path, '/api/v3/movie/7', 'movie_by_id path correct');

my $cmd = $radarr->command('RescanMovie', movieId => 7);
is($cmd->{id}, 202, 'command decoded');
is($ua->all_requests->[3]->method, 'POST', 'command uses POST');
is($ua->all_requests->[3]->uri->path, '/api/v3/command', 'command path correct');
is($json->decode($ua->all_requests->[3]->content)->{name}, 'RescanMovie', 'command payload includes name');

my $queue = $radarr->queue(page => 1, pageSize => 20);
is(ref($queue), 'HASH', 'queue decoded');
is($ua->all_requests->[4]->uri->path, '/api/v3/queue', 'queue path correct');
like($ua->all_requests->[4]->uri->query, qr/page=1/, 'queue includes page param');

my $folders = $radarr->root_folders;
is(ref($folders), 'ARRAY', 'root_folders returns arrayref');
is($ua->all_requests->[5]->uri->path, '/api/v3/rootfolder', 'root_folders path correct');

eval { $radarr->movie_by_id(q{}); 1 };
like($@, qr/movie_by_id requires id/, 'movie_by_id validates id');

eval { $radarr->command(q{}); 1 };
like($@, qr/command requires name/, 'command validates name');

done_testing;
