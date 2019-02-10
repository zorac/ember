#!/usr/bin/perl

package Ember::VFS::Dir;

use strict;
use warnings;
use base qw( Ember::VFS );

use File::Slurp;

sub _open {
    my ($self) = @_;

    return -d $self->{filename};
}

sub content {
    my ($self, $path) = @_;

    $path = $self->{filename} . '/' . $path;

    return unless (-f $path);
    return read_file($path, { binmode => ':utf8' });
}

1;
