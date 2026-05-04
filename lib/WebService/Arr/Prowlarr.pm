use v5.42;
use utf8;
use feature 'class';
no warnings 'experimental::class';

use WebService::Arr::Base;

class WebService::Arr::Prowlarr :isa(WebService::Arr::Base) {
    use Carp qw(croak);

    our $VERSION = '0.001';

    method system_status() {
        $self->get('/api/v1/system/status');
    }

    method indexers(%params) {
        $self->get('/api/v1/indexer', query => \%params);
    }

    method indexer_by_id($id) {
        croak('indexer_by_id requires id') unless defined $id && $id ne '';
        $self->get("/api/v1/indexer/$id");
    }

    method search(%params) {
        croak('search requires query') unless defined $params{query} && $params{query} ne '';
        $self->get('/api/v1/search', query => \%params);
    }

    method applications() {
        $self->get('/api/v1/applications');
    }
}

1;

=head1 NAME

WebService::Arr::Prowlarr - Thin Prowlarr API v1 client

=head1 SYNOPSIS

  use WebService::Arr::Prowlarr;

  my $prowlarr = WebService::Arr::Prowlarr->new(
      baseurl => 'http://localhost:9696',
      api_key => 'abc123',
  );

  my $status   = $prowlarr->system_status;
  my $indexers = $prowlarr->indexers;
  my $indexer  = $prowlarr->indexer_by_id(3);
  my $results  = $prowlarr->search(query => 'debian', type => 'search');
  my $apps     = $prowlarr->applications;

=head1 DESCRIPTION

L<WebService::Arr::Prowlarr> is a thin wrapper over selected Prowlarr API v1
endpoints. Transport, auth, and error handling are delegated to
L<WebService::Arr::Base>.

=head1 METHODS

=head2 system_status

Calls C<GET /api/v1/system/status>.

=head2 indexers(%params)

Calls C<GET /api/v1/indexer> with optional query params.

=head2 indexer_by_id($id)

Calls C<GET /api/v1/indexer/:id>.

=head2 search(%params)

Calls C<GET /api/v1/search>. Requires C<query> key in C<%params>.

=head2 applications

Calls C<GET /api/v1/applications>.

=head1 ERROR BEHAVIOR

Any non-2xx response is raised as an exception by the base class.

=cut
