use v5.42;
use utf8;
use feature 'class';
no warnings 'experimental::class';

use WebService::Arr::Base;

class WebService::Arr::Bazarr :isa(WebService::Arr::Base) {
    use Carp qw(croak);

    our $VERSION = '0.001';

    method system_status() {
        $self->get('/api/system/status');
    }

    method system_health() {
        $self->get('/api/system/health');
    }

    method series(%params) {
        $self->get('/api/series', query => \%params);
    }

    method episodes(%params) {
        $self->get('/api/episodes', query => \%params);
    }

    method movies(%params) {
        $self->get('/api/movies', query => \%params);
    }

    method providers(%params) {
        $self->get('/api/providers', query => \%params);
    }

    method history(%params) {
        $self->get('/api/history', query => \%params);
    }

    method badges() {
        $self->get('/api/badges');
    }
}

1;

=head1 NAME

WebService::Arr::Bazarr - Thin Bazarr subtitle API client

=head1 SYNOPSIS

  use WebService::Arr::Bazarr;

  my $bazarr = WebService::Arr::Bazarr->new(
      baseurl => 'http://localhost:6767',
      api_key => 'abc123',
  );

  my $status    = $bazarr->system_status;
  my $health    = $bazarr->system_health;
  my $series    = $bazarr->series;
  my $episodes  = $bazarr->episodes(seriesid => 42);
  my $movies    = $bazarr->movies;
  my $providers = $bazarr->providers;
  my $history   = $bazarr->history(start => 0, length => 25);
  my $badges    = $bazarr->badges;

=head1 DESCRIPTION

L<WebService::Arr::Bazarr> is a thin Perl wrapper over the Bazarr subtitle
management API. Bazarr's top-level API namespaces are subtitle-oriented
(C</api/subtitles>, C</api/providers>) and integration-oriented
(C</api/webhooks>, C</api/plex>). Health, logs, backups, and settings are
nested under C</api/system/*>.

Bazarr uses header auth (C<X-API-KEY>), same as the Servarr applications.
Default port is C<6767>.

Evidence basis: C<bazarr/bazarr/api/__init__.py> (source-verified in workspace).

=head1 CONSTRUCTOR

  my $client = WebService::Arr::Bazarr->new(
      baseurl      => 'http://localhost:6767',
      api_key      => 'token',          # optional but required in practice
      api_key_mode => 'header',         # default; Bazarr declares X-API-KEY
      timeout      => 30,               # optional
      ua           => $custom_ua,       # optional; useful for testing
  );

=head1 METHODS

=head2 system_status()

  my $status = $bazarr->system_status;

C<GET /api/system/status>. Returns a hashref of system information.

=head2 system_health()

  my $health = $bazarr->system_health;

C<GET /api/system/health>. Returns health-check data.

=head2 series(%params)

  my $series = $bazarr->series;
  my $series = $bazarr->series(start => 0, length => 50);

C<GET /api/series>. Returns an arrayref of monitored TV series.

=head2 episodes(%params)

  my $episodes = $bazarr->episodes(seriesid => 42);
  my $episodes = $bazarr->episodes(seriesid => 42, episodeid => 100);

C<GET /api/episodes>. Pass C<seriesid> to filter by series.

=head2 movies(%params)

  my $movies = $bazarr->movies;
  my $movies = $bazarr->movies(start => 0, length => 50);

C<GET /api/movies>. Returns an arrayref of monitored movies.

=head2 providers(%params)

  my $providers = $bazarr->providers;

C<GET /api/providers>. Returns available subtitle providers.

=head2 history(%params)

  my $history = $bazarr->history(start => 0, length => 25);

C<GET /api/history>. Returns subtitle download history.

=head2 badges()

  my $badges = $bazarr->badges;

C<GET /api/badges>. Returns badge counts (wanted episodes, wanted movies, etc.).

=head1 SEE ALSO

L<WebService::Arr::Base>, L<WebService::Arr>

=cut
