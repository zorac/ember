#!/usr/bin/perl

package Ember::FS;

use strict;
use warnings;
use fields qw( filename );

# TODO load submodules on demand
use Ember::FS::Dir;
use Ember::FS::Zip;

my %HINTS = (
    epub    => 'Zip',
    zip     => 'Zip',
);

sub new {
    my ($self, $filename) = @_;

    $self = fields::new($self) unless (ref($self));
    $self->{filename} = $filename;

    return $self if ($self->_open());
}

sub open {
    my ($class, $filename) = @_;

    return Ember::FS::Dir->new($filename) if (-d $filename);
    return Ember::FS::Zip->new($filename);
    
    # TODO use hints, check all...

    die('Unable to determine FS type')
}

sub _open {
    die('Cannot directly instantiate Ember::FS');
}

# To implement in subclasses:
# _open() -> bool
# content($path) -> content

1;
