use v5.42;
use utf8;
use feature 'class';
no warnings 'experimental::class';

use WebService::Arr::Base;

class WebService::Arr::Kapowarr :isa(WebService::Arr::Base) {
    use Carp qw(croak);

    our $VERSION = '0.001';

    method system_about() {
        $self->get('/api/system/about');
    }

    method tasks(%params) {
        $self->get('/api/system/tasks', query => \%params);
    }

    method settings() {
        $self->get('/api/settings');
    }

    method root_folders() {
        $self->get('/api/rootfolder');
    }

    method volumes(%params) {
        $self->get('/api/volumes', query => \%params);
    }

    method volume_by_id($id) {
        croak('volume_by_id requires id') unless defined $id && $id ne '';
        $self->get("/api/volumes/$id");
    }

    method volumes_search(%params) {
        croak('volumes_search requires query') unless defined $params{query} && $params{query} ne '';
        $self->get('/api/volumes/search', query => \%params);
    }

    method queue(%params) {
        $self->get('/api/activity/queue', query => \%params);
    }

    method history(%params) {
        $self->get('/api/activity/history', query => \%params);
    }
}

1;

=head1 NAME

WebService::Arr::Kapowarr - Thin Kapowarr comics/manga library API client

=head1 SYNOPSIS

  use WebService::Arr::Kapowarr;

  my $kapowarr = WebService::Arr::Kapowarr->new(
      baseurl      => 'http://localhost:5656',
      api_key      => 'abc123',
      api_key_mode => 'query',
  );

  my $about   = $kapowarr->system_about;
  my $volumes = $kapowarr->volumes;
  my $vol     = $kapowarr->volume_by_id(10);
  my $results = $kapowarr->volumes_search(query => 'Batman');
  my $queue   = $kapowarr->queue;
  my $history = $kapowarr->history(offset => 0, limit => 25);

=head1 DESCRIPTION

L<WebService::Arr::Kapowarr> is a thin Perl wrapper over the Kapowarr
comics and manga library manager API. Kapowarr's API is a Flask Blueprint
mounted under C</api>.

B<Auth note:> Kapowarr authenticates via an C<api_key> B<query parameter>,
not via a header. The C<Base> transport appends it as C<?apikey=...> when
C<api_key_mode> is set to C<'query'>. Always pass C<< api_key_mode => 'query' >>
when constructing a Kapowarr client.

Evidence basis: C<Kapowarr/frontend/api.py> (source-verified in workspace).
Default port is C<5656>.

=head1 CONSTRUCTOR

  my $client = WebService::Arr::Kapowarr->new(
      baseurl      => 'http://localhost:5656',
      api_key      => 'token',
      api_key_mode => 'query',   # required for Kapowarr
      timeout      => 30,        # optional
      ua           => $custom_ua,# optional; useful for testing
  );

=head1 METHODS

=head2 system_about()

  my $about = $kapowarr->system_about;

C<GET /api/system/about>. Returns version and system information.

=head2 tasks(%params)

  my $tasks = $kapowarr->tasks;

C<GET /api/system/tasks>. Returns the list of background tasks.

=head2 settings()

  my $settings = $kapowarr->settings;

C<GET /api/settings>. Returns current Kapowarr settings.

=head2 root_folders()

  my $folders = $kapowarr->root_folders;

C<GET /api/rootfolder>. Returns configured root/library folders.

=head2 volumes(%params)

  my $volumes = $kapowarr->volumes;
  my $volumes = $kapowarr->volumes(offset => 0, limit => 50, sort => 'title');

C<GET /api/volumes>. Returns the library of tracked comics/manga volumes.

=head2 volume_by_id($id)

  my $vol = $kapowarr->volume_by_id(10);

C<GET /api/volumes/:id>. Returns a single volume by its numeric ID.

=head2 volumes_search(%params)

  my $results = $kapowarr->volumes_search(query => 'Batman');

C<GET /api/volumes/search>. Searches ComicVine for volumes matching the
given C<query>. C<query> is required.

=head2 queue(%params)

  my $queue = $kapowarr->queue;

C<GET /api/activity/queue>. Returns the current download queue.

=head2 history(%params)

  my $history = $kapowarr->history(offset => 0, limit => 25);

C<GET /api/activity/history>. Returns download history.

=head1 SEE ALSO

L<WebService::Arr::Base>, L<WebService::Arr>

=cut
