use v5.42;
use utf8;
use feature 'class';
no warnings 'experimental::class';

use WebService::Arr::Sonarr;
use WebService::Arr::Radarr;
use WebService::Arr::Lidarr;
use WebService::Arr::Prowlarr;
use WebService::Arr::Whisparr;
use WebService::Arr::Dispatcharr;
use WebService::Arr::Bazarr;
use WebService::Arr::Kapowarr;

package WebService::Arr;

our $VERSION = '0.001';

sub sonarr_client      (%args) { WebService::Arr::Sonarr->new(%args)      }
sub radarr_client      (%args) { WebService::Arr::Radarr->new(%args)      }
sub lidarr_client      (%args) { WebService::Arr::Lidarr->new(%args)      }
sub prowlarr_client    (%args) { WebService::Arr::Prowlarr->new(%args)    }
sub whisparr_client    (%args) { WebService::Arr::Whisparr->new(%args)    }
sub dispatcharr_client (%args) { WebService::Arr::Dispatcharr->new(%args) }
sub bazarr_client      (%args) { WebService::Arr::Bazarr->new(%args)      }
sub kapowarr_client    (%args) { WebService::Arr::Kapowarr->new(%args)    }

1;

=head1 NAME

WebService::Arr - Factory helpers for Arr service clients

=head1 SYNOPSIS

  use WebService::Arr;

  my $sonarr      = WebService::Arr::sonarr_client(      baseurl => 'http://localhost:8989', api_key => '...' );
  my $radarr      = WebService::Arr::radarr_client(      baseurl => 'http://localhost:7878', api_key => '...' );
  my $lidarr      = WebService::Arr::lidarr_client(      baseurl => 'http://localhost:8686', api_key => '...' );
  my $prowlarr    = WebService::Arr::prowlarr_client(    baseurl => 'http://localhost:9696', api_key => '...' );
  my $whisparr    = WebService::Arr::whisparr_client(    baseurl => 'http://localhost:6969', api_key => '...' );
  my $dispatcharr = WebService::Arr::dispatcharr_client( baseurl => 'http://localhost:9191', api_key => '...' );
  my $bazarr      = WebService::Arr::bazarr_client(      baseurl => 'http://localhost:6767', api_key => '...' );
  my $kapowarr    = WebService::Arr::kapowarr_client(    baseurl => 'http://localhost:5656', api_key => '...', api_key_mode => 'query' );

=head1 FACTORY FUNCTIONS

=head2 sonarr_client(%args)

Returns L<WebService::Arr::Sonarr> (port 8989, C</api/v3/>).

=head2 radarr_client(%args)

Returns L<WebService::Arr::Radarr> (port 7878, C</api/v3/>).

=head2 lidarr_client(%args)

Returns L<WebService::Arr::Lidarr> (port 8686, C</api/v1/>).

=head2 prowlarr_client(%args)

Returns L<WebService::Arr::Prowlarr> (port 9696, C</api/v1/>).

=head2 whisparr_client(%args)

Returns L<WebService::Arr::Whisparr> (port 6969, C</api/v3/>).

=head2 dispatcharr_client(%args)

Returns L<WebService::Arr::Dispatcharr> (port 9191, C</api/*> JSON endpoints).

=head2 bazarr_client(%args)

Returns L<WebService::Arr::Bazarr> (port 6767, C</api/*>). Uses header auth (C<X-API-KEY>).

=head2 kapowarr_client(%args)

Returns L<WebService::Arr::Kapowarr> (port 5656, C</api/*>). Uses query-param auth.
Pass C<< api_key_mode => 'query' >> explicitly.

=cut
