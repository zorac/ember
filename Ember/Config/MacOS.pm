#!/usr/bin/perl

package Ember::Config::MacOS;

use strict;
use warnings;
use base qw( Ember::Config );

sub _open {
    my ($self) = @_;
    my $appsupport = $ENV{HOME} . '/Library/Application Support';
    my $dir = $appsupport . '/Ember';

    die('Failed to locate Application Support folder') unless (-d $appsupport);
    mkdir($dir) unless (-d $dir);

    $self->{dir} = $dir;

    return 1;
}

1;
