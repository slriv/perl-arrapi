use v5.42;
use utf8;

use lib 't/lib';

use HTTP::Response;
use JSON::XS;
use Test::More;

use FakeArr;
use WebService::Arr::Lidarr;

my $json = JSON::XS->new->utf8;

my $ua = FakeArr->new(
    responses => [
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"version":"2.0"}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":1}]'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"id":1,"artistName":"Björk"}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '[{"id":10}]'),
        HTTP::Response->new(201, 'Created', [ 'Content-Type' => 'application/json' ], '{"id":303}'),
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{"records":[]}'),
    ],
);

my $lidarr = WebService::Arr::Lidarr->new(
    baseurl => 'http://lidarr.local',
    api_key => 'LID',
    ua      => $ua,
);

my $status = $lidarr->system_status;
is($status->{version}, '2.0', 'system_status decoded');
is($ua->all_requests->[0]->method, 'GET', 'system_status uses GET');
is($ua->all_requests->[0]->uri->path, '/api/v1/system/status', 'system_status path correct');

my $artists = $lidarr->artists;
is(ref($artists), 'ARRAY', 'artists returns arrayref');
is($ua->all_requests->[1]->uri->path, '/api/v1/artist', 'artists path correct');

my $artist = $lidarr->artist_by_id(1);
is($artist->{artistName}, 'Björk', 'artist_by_id decoded');
is($ua->all_requests->[2]->uri->path, '/api/v1/artist/1', 'artist_by_id path correct');

my $albums = $lidarr->albums(artistId => 1);
is(ref($albums), 'ARRAY', 'albums returns arrayref');
is($ua->all_requests->[3]->uri->path, '/api/v1/album', 'albums path correct');
like($ua->all_requests->[3]->uri->query, qr/artistId=1/, 'albums passes artistId param');

my $cmd = $lidarr->command('RescanArtist', artistId => 1);
is($cmd->{id}, 303, 'command decoded');
is($ua->all_requests->[4]->method, 'POST', 'command uses POST');
is($ua->all_requests->[4]->uri->path, '/api/v1/command', 'command path correct');
is($json->decode($ua->all_requests->[4]->content)->{name}, 'RescanArtist', 'command payload includes name');

my $queue = $lidarr->queue(page => 1);
is(ref($queue), 'HASH', 'queue decoded');
is($ua->all_requests->[5]->uri->path, '/api/v1/queue', 'queue path correct');
like($ua->all_requests->[5]->uri->query, qr/page=1/, 'queue includes page param');

eval { $lidarr->artist_by_id(q{}); 1 };
like($@, qr/artist_by_id requires id/, 'artist_by_id validates id');

eval { $lidarr->command(q{}); 1 };
like($@, qr/command requires name/, 'command validates name');

done_testing;
