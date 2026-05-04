use v5.42;
use utf8;
use feature 'class';
no warnings 'experimental::class';

use WebService::Arr::Base;

class WebService::Arr::Radarr :isa(WebService::Arr::Base) {
    use Carp qw(croak);

    our $VERSION = '0.001';

    method system_status() {
        $self->get('/api/v3/system/status');
    }

    method movies(%params) {
        $self->get('/api/v3/movie', query => \%params);
    }

    method movie_by_id($id) {
        croak('movie_by_id requires id') unless defined $id && $id ne '';
        $self->get("/api/v3/movie/$id");
    }

    method command($name, %payload) {
        croak('command requires name') unless defined $name && $name ne '';
        $payload{name} = $name;
        $self->post('/api/v3/command', data => \%payload);
    }

    method queue(%params) {
        $self->get('/api/v3/queue', query => \%params);
    }

    method root_folders() {
        $self->get('/api/v3/rootfolder');
    }
}

1;

=head1 NAME

WebService::Arr::Radarr - Thin Radarr API v3 client

=head1 SYNOPSIS

  use WebService::Arr::Radarr;

  my $radarr = WebService::Arr::Radarr->new(
      baseurl => 'http://localhost:7878',
      api_key => 'abc123',
  );

  my $status  = $radarr->system_status;
  my $all     = $radarr->movies;
  my $one     = $radarr->movie_by_id(42);
  my $cmd     = $radarr->command('RescanMovie', movieId => 42);
  my $queue   = $radarr->queue(page => 1, pageSize => 20);
  my $folders = $radarr->root_folders;

=head1 DESCRIPTION

L<WebService::Arr::Radarr> is a thin wrapper over selected Radarr API v3
endpoints. Transport, auth, and error handling are delegated to
L<WebService::Arr::Base>.

=head1 METHODS

=head2 system_status

Calls C<GET /api/v3/system/status>.

=head2 movies(%params)

Calls C<GET /api/v3/movie> with optional query params.

=head2 movie_by_id($id)

Calls C<GET /api/v3/movie/:id>.

=head2 command($name, %payload)

Calls C<POST /api/v3/command> with C<name> and payload fields.

=head2 queue(%params)

Calls C<GET /api/v3/queue> with optional query params.

=head2 root_folders

Calls C<GET /api/v3/rootfolder>.

=head1 ERROR BEHAVIOR

Any non-2xx response is raised as an exception by the base class.

=cut