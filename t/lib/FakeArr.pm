use v5.42;
use utf8;
use feature 'class';
no warnings 'experimental::class';

use HTTP::Response;

class FakeArr {
    field $responses    :param = undef;
    field $last_request;
    field $all_requests;

    ADJUST {
        $responses    //= [];
        $all_requests   = [];
    }

    method push_response($res) {
        push @{$responses}, $res;
    }

    method request($req) {
        $last_request = $req;
        push @{$all_requests}, $req;

        my $res = shift @{$responses};
        return $res if $res;

        return HTTP::Response->new(
            500,
            'No fake response queued',
            [ 'Content-Type' => 'application/json' ],
            '{"error":"no fake response queued"}'
        );
    }

    method last_request() { $last_request }
    method all_requests() { $all_requests }
}

1;