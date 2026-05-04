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

    method episodes(%params) {
        $self->get('/api/v3/episode', query => \%params);
    }

    method episode_by_id($id) {
        croak('episode_by_id requires id') unless defined $id && $id ne '';
        $self->get("/api/v3/episode/$id");
    }

    method calendar(%params) {
        $self->get('/api/v3/calendar', query => \%params);
    }

    method history(%params) {
        $self->get('/api/v3/history', query => \%params);
    }

    method wanted_missing(%params) {
        $self->get('/api/v3/wanted/missing', query => \%params);
    }

    method wanted_cutoff(%params) {
        $self->get('/api/v3/wanted/cutoff', query => \%params);
    }

    method health() {
        $self->get('/api/v3/health');
    }

    method tags() {
        $self->get('/api/v3/tag');
    }

    method tag_by_id($id) {
        croak('tag_by_id requires id') unless defined $id && $id ne '';
        $self->get("/api/v3/tag/$id");
    }

    method root_folders() {
        $self->get('/api/v3/rootfolder');
    }

    method blocklist(%params) {
        $self->get('/api/v3/blocklist', query => \%params);
    }

    method disk_space() {
        $self->get('/api/v3/diskspace');
    }

    method update_series($id, $data) {
        croak('update_series requires id')   unless defined $id   && $id   ne '';
        croak('update_series requires data') unless defined $data && ref $data;
        $self->put("/api/v3/series/$id", data => $data);
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

  my $status  = $sonarr->system_status;
  my $all     = $sonarr->series;
  my $one     = $sonarr->series_by_id(42);
  my $cmd     = $sonarr->command('RescanSeries', seriesId => 42);
  my $queue   = $sonarr->queue(page => 1, pageSize => 20);
  my $eps     = $sonarr->episodes(seriesId => 42);
  my $ep      = $sonarr->episode_by_id(101);
  my $cal     = $sonarr->calendar(start => '2026-05-01', end => '2026-05-07');
  my $hist    = $sonarr->history(page => 1, pageSize => 20);
  my $missing = $sonarr->wanted_missing(page => 1);
  my $cutoff  = $sonarr->wanted_cutoff(page => 1);
  my $health  = $sonarr->health;
  my $tags    = $sonarr->tags;
  my $tag     = $sonarr->tag_by_id(3);
  my $roots   = $sonarr->root_folders;
  my $block   = $sonarr->blocklist(page => 1);
  my $disk    = $sonarr->disk_space;

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

=head2 episodes(%params)

Calls C<GET /api/v3/episode>. Accepts C<seriesId>, C<seasonNumber>, C<episodeFileId>, etc.

=head2 episode_by_id($id)

Calls C<GET /api/v3/episode/:id>.

=head2 calendar(%params)

Calls C<GET /api/v3/calendar>. Accepts C<start>, C<end>, C<unmonitored>, etc.

=head2 history(%params)

Calls C<GET /api/v3/history> with paging and filter params.

=head2 wanted_missing(%params)

Calls C<GET /api/v3/wanted/missing> with paging params.

=head2 wanted_cutoff(%params)

Calls C<GET /api/v3/wanted/cutoff> with paging params.

=head2 health()

Calls C<GET /api/v3/health>.

=head2 tags()

Calls C<GET /api/v3/tag>.

=head2 tag_by_id($id)

Calls C<GET /api/v3/tag/:id>.

=head2 root_folders()

Calls C<GET /api/v3/rootfolder>.

=head2 blocklist(%params)

Calls C<GET /api/v3/blocklist> with paging params.

=head2 disk_space()

Calls C<GET /api/v3/diskspace>.

=head2 update_series($id, $data)

Calls C<PUT /api/v3/series/:id> with C<$data> as the JSON body. Returns the updated series object.

=head1 ERROR BEHAVIOR

Any non-2xx response is raised as an exception by the base class.

=cut