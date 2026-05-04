use v5.42;
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'WebService::Arr',
    VERSION_FROM => 'lib/WebService/Arr.pm',
    ABSTRACT     => 'Thin Perl clients for Arr services (Sonarr/Radarr/etc)',
    AUTHOR       => 'arrapi contributors',
    LICENSE      => 'perl',
    PREREQ_PM    => {
        'Carp'                 => 0,
        'Exporter'             => 0,
        'HTTP::Request'        => 0,
        'JSON::XS'             => 0,
        'LWP::UserAgent'       => 0,
        'Test::More'           => 0,
        'URI::Escape'          => 0,
        'parent'               => 0,
    },
    MIN_PERL_VERSION => '5.042',
    test             => { TESTS => 't/*.t' },
    META_MERGE       => {
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/slriv/perl-arrapi.git',
            },
        },
    },
);