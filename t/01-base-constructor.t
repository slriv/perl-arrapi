use v5.42;
use utf8;

use lib 't/lib';

use HTTP::Response;
use Test::More;

use FakeArr;
use WebService::Arr::Base;

eval { WebService::Arr::Base->new(); 1 };
like($@, qr/baseurl is required/, 'baseurl is required');

my $default = WebService::Arr::Base->new(baseurl => 'http://arr.local/');
is($default->baseurl, 'http://arr.local', 'trailing slash removed from baseurl');
is($default->timeout, 30, 'default timeout is 30');
is($default->api_key_mode, 'header', 'default api_key_mode is header');

eval {
    WebService::Arr::Base->new(
        baseurl      => 'http://arr.local',
        api_key_mode => 'invalid',
    );
    1;
};
like($@, qr/api_key_mode must be 'header' or 'query'/, 'invalid api_key_mode rejected');

my $header_ua = FakeArr->new(
    responses => [
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{}'),
    ],
);

my $header_client = WebService::Arr::Base->new(
    baseurl      => 'http://arr.local',
    api_key      => 'SECRET',
    api_key_mode => 'header',
    ua           => $header_ua,
);

$header_client->get('/api/v3/system/status');
my $header_req = $header_ua->last_request;
is($header_req->header('X-Api-Key'), 'SECRET', 'header mode sets X-Api-Key');
unlike($header_req->uri->as_string, qr/apikey=/, 'header mode does not set apikey query');

my $query_ua = FakeArr->new(
    responses => [
        HTTP::Response->new(200, 'OK', [ 'Content-Type' => 'application/json' ], '{}'),
    ],
);

my $query_client = WebService::Arr::Base->new(
    baseurl      => 'http://arr.local',
    api_key      => 'SECRET',
    api_key_mode => 'query',
    ua           => $query_ua,
);

$query_client->get('/api/v3/system/status', query => { page => 2 });
my $query_req = $query_ua->last_request;
ok($query_req->uri->as_string =~ /apikey=SECRET/, 'query mode appends apikey param');
ok($query_req->uri->as_string =~ /page=2/, 'existing query params preserved');
ok(!defined $query_req->header('X-Api-Key'), 'query mode omits X-Api-Key header');

done_testing;