use v5.42;
use utf8;
use feature 'class';
no warnings 'experimental::class';

use WebService::Arr::Base;

class WebService::Arr::Dispatcharr :isa(WebService::Arr::Base) {
    use Carp qw(croak);

    our $VERSION = '0.001';

    method core_version() {
        $self->get('/api/core/version/');
    }

    method core_environment() {
        $self->get('/api/core/settings/env/');
    }

    method system_events() {
        $self->get('/api/core/system-events/');
    }

    method channels(%params) {
        $self->get('/api/channels/channels/', query => \%params);
    }

    method channel_by_id($id) {
        croak('channel_by_id requires id') unless defined $id && $id ne '';
        $self->get("/api/channels/channels/$id/");
    }

    method m3u_accounts(%params) {
        $self->get('/api/m3u/accounts/', query => \%params);
    }

    method epg_sources(%params) {
        $self->get('/api/epg/sources/', query => \%params);
    }
}

1;

=head1 NAME

WebService::Arr::Dispatcharr - Thin Dispatcharr JSON API client

=head1 SYNOPSIS

  use WebService::Arr::Dispatcharr;

  my $dispatcharr = WebService::Arr::Dispatcharr->new(
      baseurl => 'http://localhost:9191',
      api_key => 'abc123',
  );

  my $version  = $dispatcharr->core_version;
  my $channels = $dispatcharr->channels;
  my $m3u      = $dispatcharr->m3u_accounts;
  my $epg      = $dispatcharr->epg_sources;

=head1 DESCRIPTION

L<WebService::Arr::Dispatcharr> is a thin wrapper over selected Dispatcharr
JSON API endpoints. It intentionally focuses on JSON-first endpoints under
C</api/*>. Transport, auth, and error handling are delegated to
L<WebService::Arr::Base>.

=head1 METHODS

=head2 core_version

Calls C<GET /api/core/version/>.

=head2 core_environment

Calls C<GET /api/core/settings/env/>.

=head2 system_events

Calls C<GET /api/core/system-events/>.

=head2 channels(%params)

Calls C<GET /api/channels/channels/> with optional query params.

=head2 channel_by_id($id)

Calls C<GET /api/channels/channels/:id/>.

=head2 m3u_accounts(%params)

Calls C<GET /api/m3u/accounts/> with optional query params.

=head2 epg_sources(%params)

Calls C<GET /api/epg/sources/> with optional query params.

=head1 ERROR BEHAVIOR

Any non-2xx response is raised as an exception by the base class.

=cut