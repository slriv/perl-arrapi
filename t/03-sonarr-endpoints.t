use v5.42;
use utf8;

use lib 't/lib';

use HTTP::Response;
use JSON::XS;
use Test::More;

use FakeArr;
use WebService::Arr::Sonarr;

my $json = JSON::XS->new->utf8;

sub ok_resp { HTTP::Response->new(200, 'OK', ['Content-Type' => 'application/json'], $_[0]) }
sub created  { HTTP::Response->new(201, 'Created', ['Content-Type' => 'application/json'], $_[0]) }

my $ua = FakeArr->new(
    responses => [
        ok_resp('{"version":"4.0"}'),             # 0  system_status
        ok_resp('[]'),                            # 1  series
        ok_resp('{"id":9}'),                      # 2  series_by_id
        created('{"id":101}'),                    # 3  command
        ok_resp('{"records":[]}'),                # 4  queue
        ok_resp('[{"id":5,"title":"Pilot"}]'),    # 5  episodes
        ok_resp('{"id":5,"title":"Pilot"}'),      # 6  episode_by_id
        ok_resp('[{"id":7}]'),                    # 7  calendar
        ok_resp('{"records":[{"id":8}]}'),        # 8  history
        ok_resp('{"records":[{"id":9}]}'),        # 9  wanted_missing
        ok_resp('{"records":[{"id":10}]}'),       # 10 wanted_cutoff
        ok_resp('[{"source":"NzbDrone"}]'),       # 11 health
        ok_resp('[{"id":1,"label":"hd"}]'),       # 12 tags
        ok_resp('{"id":1,"label":"hd"}'),         # 13 tag_by_id
        ok_resp('[{"path":"/media"}]'),           # 14 root_folders
        ok_resp('{"records":[{"id":11}]}'),       # 15 blocklist
        ok_resp('[{"path":"/","freeSpace":100}]'),# 16 disk_space
        ok_resp('{"id":9,"path":"/tv/new"}'),    # 17 update_series
    ],
);

my $sonarr = WebService::Arr::Sonarr->new(
    baseurl => 'http://sonarr.local',
    api_key => 'ABC',
    ua      => $ua,
);

# system_status
my $status = $sonarr->system_status;
is($status->{version}, '4.0', 'system_status decoded');
is($ua->all_requests->[0]->method, 'GET', 'system_status uses GET');
is($ua->all_requests->[0]->uri->path, '/api/v3/system/status', 'system_status path');

# series
my $series = $sonarr->series;
is(ref($series), 'ARRAY', 'series returns arrayref');
is($ua->all_requests->[1]->uri->path, '/api/v3/series', 'series path');

# series_by_id
my $series_one = $sonarr->series_by_id(9);
is($series_one->{id}, 9, 'series_by_id decoded');
is($ua->all_requests->[2]->uri->path, '/api/v3/series/9', 'series_by_id path');

# command
my $cmd = $sonarr->command('RescanSeries', seriesId => 9);
is($cmd->{id}, 101, 'command decoded');
is($ua->all_requests->[3]->method, 'POST', 'command uses POST');
is($ua->all_requests->[3]->uri->path, '/api/v3/command', 'command path');
is($json->decode($ua->all_requests->[3]->content)->{name}, 'RescanSeries', 'command payload name');

# queue
my $queue = $sonarr->queue(page => 1, pageSize => 20);
is(ref($queue), 'HASH', 'queue decoded');
is($ua->all_requests->[4]->uri->path, '/api/v3/queue', 'queue path');
like($ua->all_requests->[4]->uri->query, qr/page=1/, 'queue query page');
like($ua->all_requests->[4]->uri->query, qr/pageSize=20/, 'queue query pageSize');

# episodes
my $eps = $sonarr->episodes(seriesId => 9);
is(ref($eps), 'ARRAY', 'episodes returns arrayref');
is($eps->[0]{id}, 5, 'episodes decoded');
is($ua->all_requests->[5]->uri->path, '/api/v3/episode', 'episodes path');
like($ua->all_requests->[5]->uri->query, qr/seriesId=9/, 'episodes query seriesId');

# episode_by_id
my $ep = $sonarr->episode_by_id(5);
is($ep->{id}, 5, 'episode_by_id decoded');
is($ua->all_requests->[6]->uri->path, '/api/v3/episode/5', 'episode_by_id path');

# calendar
my $cal = $sonarr->calendar(start => '2026-05-01', end => '2026-05-07');
is(ref($cal), 'ARRAY', 'calendar returns arrayref');
is($ua->all_requests->[7]->uri->path, '/api/v3/calendar', 'calendar path');
like($ua->all_requests->[7]->uri->query, qr/start=/, 'calendar query start');

# history
my $hist = $sonarr->history(page => 1, pageSize => 10);
is(ref($hist), 'HASH', 'history decoded');
is($ua->all_requests->[8]->uri->path, '/api/v3/history', 'history path');

# wanted_missing
my $missing = $sonarr->wanted_missing(page => 1);
is(ref($missing), 'HASH', 'wanted_missing decoded');
is($ua->all_requests->[9]->uri->path, '/api/v3/wanted/missing', 'wanted_missing path');

# wanted_cutoff
my $cutoff = $sonarr->wanted_cutoff(page => 1);
is(ref($cutoff), 'HASH', 'wanted_cutoff decoded');
is($ua->all_requests->[10]->uri->path, '/api/v3/wanted/cutoff', 'wanted_cutoff path');

# health
my $health = $sonarr->health;
is(ref($health), 'ARRAY', 'health returns arrayref');
is($ua->all_requests->[11]->uri->path, '/api/v3/health', 'health path');

# tags
my $tags = $sonarr->tags;
is(ref($tags), 'ARRAY', 'tags returns arrayref');
is($ua->all_requests->[12]->uri->path, '/api/v3/tag', 'tags path');

# tag_by_id
my $tag = $sonarr->tag_by_id(1);
is($tag->{label}, 'hd', 'tag_by_id decoded');
is($ua->all_requests->[13]->uri->path, '/api/v3/tag/1', 'tag_by_id path');

# root_folders
my $roots = $sonarr->root_folders;
is(ref($roots), 'ARRAY', 'root_folders returns arrayref');
is($ua->all_requests->[14]->uri->path, '/api/v3/rootfolder', 'root_folders path');

# blocklist
my $block = $sonarr->blocklist(page => 1);
is(ref($block), 'HASH', 'blocklist decoded');
is($ua->all_requests->[15]->uri->path, '/api/v3/blocklist', 'blocklist path');

# disk_space
my $disk = $sonarr->disk_space;
is(ref($disk), 'ARRAY', 'disk_space returns arrayref');
is($ua->all_requests->[16]->uri->path, '/api/v3/diskspace', 'disk_space path');

# update_series
my $updated = $sonarr->update_series(9, { id => 9, path => '/tv/new' });
is($updated->{path}, '/tv/new', 'update_series decoded');
is($ua->all_requests->[17]->method, 'PUT', 'update_series uses PUT');
is($ua->all_requests->[17]->uri->path, '/api/v3/series/9', 'update_series path');
is($json->decode($ua->all_requests->[17]->content)->{path}, '/tv/new', 'update_series body');

# validation guards
eval { $sonarr->series_by_id(q{}) };
like($@, qr/series_by_id requires id/, 'series_by_id validates id');

eval { $sonarr->command(q{}) };
like($@, qr/command requires name/, 'command validates name');

eval { $sonarr->episode_by_id(q{}) };
like($@, qr/episode_by_id requires id/, 'episode_by_id validates id');

eval { $sonarr->tag_by_id(q{}) };
like($@, qr/tag_by_id requires id/, 'tag_by_id validates id');

eval { $sonarr->update_series(q{}, {}) };
like($@, qr/update_series requires id/, 'update_series validates id');

eval { $sonarr->update_series(9, undef) };
like($@, qr/update_series requires data/, 'update_series validates data');

done_testing;
