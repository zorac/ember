use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Ember',
    AUTHOR              => 'Mark Rigby-Jones <mark@rigby-jones.net>',
    VERSION_FROM        => 'lib/Ember.pm',
    ABSTRACT_FROM       => 'lib/Ember.pm',
    LICENSE             => 'artistic_2',
    EXE_FILES           => [ 'bin/ember' ],
    MIN_PERL_VERSION    => '5.006',
    CONFIGURE_REQUIRES  => {
        'ExtUtils::MakeMaker' => '0',
    },
    BUILD_REQUIRES => {
        'Test::More' => '0',
    },
    PREREQ_PM => {
        'Archive::Zip'      => '0',
        'File::Slurp'       => '0',
        'HTML::FormatText'  => '0',
        'Term::ANSIScreen'  => '0',
        'Term::ReadKey'     => '0',
        'XML::Simple'       => '0',
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Ember-*' },
);
