use v5.42;
use utf8;

use lib 't/lib';

use HTTP::Response;
use JSON::XS;
use Test::More;

use FakeArr;
use WebService::Arr::Base;

my $json = JSON::XS->new->utf8;

my $ua = FakeArr->new(
    responses => [
        HTTP::Response->new(
            200,
            'OK',
            [ 'Content-Type' => 'application/json' ],
            '{"ok":true,"name":"sonarr"}'
        ),
        HTTP::Response->new(
            200,
            'OK',
            [ 'Content-Type' => 'application/json' ],
            '{"id":123}'
        ),
    ],
);

my $client = WebService::Arr::Base->new(
    baseurl => 'http://arr.local',
    ua      => $ua,
);

my $decoded = $client->get('/api/v3/system/status');
is($decoded->{name}, 'sonarr', 'GET returns decoded JSON');

my $posted = $client->post('/api/v3/command', data => { name => 'RescanSeries', seriesId => 5 });
is($posted->{id}, 123, 'POST returns decoded JSON');

my $req = $ua->last_request;
is($req->method, 'POST', 'POST method used');
is($req->header('Content-Type'), 'application/json', 'JSON content type set');
is($json->decode($req->content)->{name}, 'RescanSeries', 'payload JSON encoded');

my $err_ua = FakeArr->new(
    responses => [
        HTTP::Response->new(
            400,
            'Bad Request',
            [ 'Content-Type' => 'application/json' ],
            '{"message":"invalid input"}'
        ),
    ],
);

my $err_client = WebService::Arr::Base->new(
    baseurl => 'http://arr.local',
    ua      => $err_ua,
);

eval { $err_client->get('/api/v3/queue'); 1 };
like($@, qr/GET http:\/\/arr\.local\/api\/v3\/queue failed: 400 Bad Request/, 'error includes method/url/status');
like($@, qr/body=.*invalid input/, 'error includes response body snippet');

done_testing;