use v5.42;
use utf8;
use feature 'class';
no warnings 'experimental::class';

class WebService::Arr::Base {
    use Carp       qw(croak);
    use HTTP::Request;
    use JSON::XS;
    use LWP::UserAgent;
    use URI::Escape qw(uri_escape_utf8);

    our $VERSION = '0.001';

    field $baseurl      :param = undef;
    field $api_key      :param = undef;
    field $timeout      :param = 30;
    field $api_key_mode :param = 'header';
    field $ua           :param = undef;
    field $_json_enc;
    field $_json_dec;

    ADJUST {
        croak('baseurl is required') unless defined $baseurl;
        $baseurl =~ s{/$}{};
        croak("api_key_mode must be 'header' or 'query'")
            unless $api_key_mode eq 'header' || $api_key_mode eq 'query';
        $ua       //= LWP::UserAgent->new(timeout => $timeout);
        $_json_enc  = JSON::XS->new->utf8->canonical;   # bytes out
        $_json_dec  = JSON::XS->new->canonical;          # decoded_content is already Unicode
    }

    method baseurl()      { $baseurl }
    method timeout()      { $timeout }
    method api_key_mode() { $api_key_mode }

    method get($path, %args)    { $self->_request('GET',    $path, %args) }
    method post($path, %args)   { $self->_request('POST',   $path, %args) }
    method put($path, %args)    { $self->_request('PUT',    $path, %args) }
    method delete($path, %args) { $self->_request('DELETE', $path, %args) }

    method _request($http_method, $path, %args) {
        my $query = $args{query} // {};
        my $data  = $args{data};

        my $url = $self->_build_url($path, $query);
        my $req = HTTP::Request->new($http_method => $url);

        $req->header('Accept'     => 'application/json');
        $req->header('User-Agent' => "WebService-Arr/$VERSION ($^O/perl-$])");
        $req->header('X-Client'   => "WebService::Arr::Base/$VERSION");

        if (defined $api_key && $api_key_mode eq 'header') {
            $req->header('X-Api-Key' => $api_key);
        }

        if (defined $data) {
            $req->header('Content-Type' => 'application/json');
            $req->content($_json_enc->encode($data));
        }

        my $res = $ua->request($req);

        if (!$res->is_success) {
            my $body = $res->decoded_content // '';
            $body =~ s/\s+/ /g;
            croak(sprintf('%s %s failed: %s %s; body=%s',
                $http_method, $url, $res->code, ($res->message // ''),
                substr($body, 0, 300),
            ));
        }

        my $content = $res->decoded_content;
        return undef if !defined $content || $content eq '';
        return $_json_dec->decode($content);
    }

    method _build_url($path, $query) {
        my $norm = $path =~ m{^/} ? $path : "/$path";
        my %qp   = %{ $query // {} };
        $qp{apikey} = $api_key if defined $api_key && $api_key_mode eq 'query';
        my $qstr = _encode_query(\%qp);
        return $qstr eq '' ? "$baseurl$norm" : "$baseurl$norm?$qstr";
    }

    sub _encode_query ($hash) {
        return '' unless $hash && %{$hash};
        my @pairs;
        for my $k (sort keys %{$hash}) {
            my $v = $hash->{$k};
            next unless defined $v;
            if (ref $v eq 'ARRAY') {
                push @pairs, map { _qp_pair($k, $_) } grep { defined } @{$v};
            } else {
                push @pairs, _qp_pair($k, $v);
            }
        }
        return join('&', @pairs);
    }

    sub _qp_pair ($k, $v) {
        return uri_escape_utf8($k) . '=' . uri_escape_utf8("$v");
    }
}