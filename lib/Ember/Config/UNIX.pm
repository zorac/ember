#!/usr/bin/perl

package Ember::Config::UNIX;

use strict;
use warnings;
use base qw( Ember::Config );

sub _open {
    my ($self) = @_;
    my $dir = $ENV{HOME} . '/.ember';

    mkdir($dir) unless (-d $dir);

    $self->{dir} = $dir;

    return 1;
}

1;
