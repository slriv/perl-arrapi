use v5.42;
use utf8;
use feature 'class';
no warnings 'experimental::class';

use WebService::Arr::Base;

class WebService::Arr::Sonarr :isa(WebService::Arr::Base) {
    use Carp qw(croak);

    our $VERSION = '0.001';

    method system_status() {
        $self->get('/api/v3/system/status');
    }

    method series() {
        $self->get('/api/v3/series');
    }

    method series_by_id($id) {
        croak('series_by_id requires id') unless defined $id && $id ne '';
        $self->get("/api/v3/series/$id");
    }

    method command($name, %payload) {
        croak('command requires name') unless defined $name && $name ne '';
        $payload{name} = $name;
        $self->post('/api/v3/command', data => \%payload);
    }

    method queue(%params) {
        $self->get('/api/v3/queue', query => \%params);
    }
}

1;

=head1 NAME

WebService::Arr::Sonarr - Thin Sonarr API v3 client

=head1 SYNOPSIS

  use WebService::Arr::Sonarr;

  my $sonarr = WebService::Arr::Sonarr->new(
      baseurl => 'http://localhost:8989',
      api_key => 'token123',
  );

  my $status = $sonarr->system_status;
  my $all    = $sonarr->series;
  my $one    = $sonarr->series_by_id(42);
  my $cmd    = $sonarr->command('RescanSeries', seriesId => 42);
  my $queue  = $sonarr->queue(page => 1, pageSize => 20);

=head1 DESCRIPTION

L<WebService::Arr::Sonarr> is a practical, thin wrapper over selected Sonarr
API v3 endpoints. It delegates transport/auth/error behavior to
L<WebService::Arr::Base> and returns decoded Perl structures.

=head1 METHODS

=head2 system_status

Calls C<GET /api/v3/system/status>.

=head2 series

Calls C<GET /api/v3/series>.

=head2 series_by_id($id)

Calls C<GET /api/v3/series/:id>.

=head2 command($name, %payload)

Calls C<POST /api/v3/command> with C<name> and payload fields.

=head2 queue(%params)

Calls C<GET /api/v3/queue> with query params.

=head1 ERROR BEHAVIOR

Any non-2xx response is raised as an exception by the base class.

=cut