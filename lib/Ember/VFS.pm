#!/usr/bin/perl

package Ember::VFS;

use strict;
use warnings;
use fields qw( filename );

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

    if (-d $filename) {
        require Ember::VFS::Dir;
        return Ember::VFS::Dir->new($filename)
    } else {
        require Ember::VFS::Zip;
        return Ember::VFS::Zip->new($filename);
    }

    # TODO use hints, check all...

    die('Unable to determine VFS type')
}

sub _open {
    die('Cannot directly instantiate Ember::VFS');
}

# To implement in subclasses:
# _open() -> bool
# content($path) -> content

1;
