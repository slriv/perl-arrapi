use v5.42;
use utf8;
use feature 'class';
no warnings 'experimental::class';

use WebService::Arr::Base;

class WebService::Arr::Lidarr :isa(WebService::Arr::Base) {
    use Carp qw(croak);

    our $VERSION = '0.001';

    method system_status() {
        $self->get('/api/v1/system/status');
    }

    method artists(%params) {
        $self->get('/api/v1/artist', query => \%params);
    }

    method artist_by_id($id) {
        croak('artist_by_id requires id') unless defined $id && $id ne '';
        $self->get("/api/v1/artist/$id");
    }

    method albums(%params) {
        $self->get('/api/v1/album', query => \%params);
    }

    method command($name, %payload) {
        croak('command requires name') unless defined $name && $name ne '';
        $payload{name} = $name;
        $self->post('/api/v1/command', data => \%payload);
    }

    method queue(%params) {
        $self->get('/api/v1/queue', query => \%params);
    }
}

1;

=head1 NAME

WebService::Arr::Lidarr - Thin Lidarr API v1 client

=head1 SYNOPSIS

  use WebService::Arr::Lidarr;

  my $lidarr = WebService::Arr::Lidarr->new(
      baseurl => 'http://localhost:8686',
      api_key => 'abc123',
  );

  my $status  = $lidarr->system_status;
  my $artists = $lidarr->artists;
  my $artist  = $lidarr->artist_by_id(7);
  my $albums  = $lidarr->albums(artistId => 7);
  my $cmd     = $lidarr->command('RescanArtist', artistId => 7);
  my $queue   = $lidarr->queue(page => 1, pageSize => 20);

=head1 DESCRIPTION

L<WebService::Arr::Lidarr> is a thin wrapper over selected Lidarr API v1
endpoints. Transport, auth, and error handling are delegated to
L<WebService::Arr::Base>.

=head1 METHODS

=head2 system_status

Calls C<GET /api/v1/system/status>.

=head2 artists(%params)

Calls C<GET /api/v1/artist> with optional query params.

=head2 artist_by_id($id)

Calls C<GET /api/v1/artist/:id>.

=head2 albums(%params)

Calls C<GET /api/v1/album> with optional query params (e.g. C<artistId>).

=head2 command($name, %payload)

Calls C<POST /api/v1/command> with C<name> and payload fields.

=head2 queue(%params)

Calls C<GET /api/v1/queue> with optional query params.

=head1 ERROR BEHAVIOR

Any non-2xx response is raised as an exception by the base class.

=cut
