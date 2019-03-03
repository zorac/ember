use 5.008;
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Ember',
    AUTHOR              => 'Mark Rigby-Jones <mark@rigby-jones.net>',
    VERSION_FROM        => 'lib/Ember.pm',
    ABSTRACT_FROM       => 'lib/Ember.pm',
    LICENSE             => 'artistic_2',
    MIN_PERL_VERSION    => '5.008',
    EXE_FILES           => [ 'bin/ember' ],
    PL_FILES            => { 'bin/build.PL' => 'bin/ember' },
    TEST_REQUIRES       => {
        'Test::More'    => '0',
    },
    PREREQ_PM           => {
        'Archive::Zip'  => '0',
        'File::Slurp'   => '0',
        'HTML::Tree'    => '5',
        'JSON'          => '0',
        'Term::ReadKey' => '0',
        'XML::Simple'   => '0',
    },
    dist                => {
        COMPRESS        => 'gzip -9f',
        SUFFIX          => 'gz',
    },
    clean => {
        FILES           => 'Ember-*'
    },
);
