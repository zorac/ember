#!/usr/bin/perl

package Ember::Book;

use strict;
use warnings;
use fields qw( filename vfs chapters );

use Ember::VFS;

my %HINTS = (
    epub    => 'EPub',
);

sub new {
    my ($self, $vfs) = @_;
    my $filename = $vfs->{filename};

    $self = fields::new($self) unless (ref($self));
    $self->{vfs} = $vfs;
    $self->{filename} = $filename;
    $self->{chapters} = [];

    return $self if ($self->_open());
}

sub open {
    my ($class, $vfs) = @_;

    $vfs = Ember::VFS->open($vfs) if (!$vfs->isa('Ember::VFS'));

    if (1) {
        require Ember::EPub::Book;
        return Ember::EPub::Book->new($vfs);
    }

    # TODO support other formats

    die('Unable to determine format');
}

sub _open {
    die('Cannot directly instantiate Ember::Book');
}

sub chapter {
    my ($self, $name) = @_;
    my $first;

    foreach my $chapter (@{$self->{chapters}}) {
        $first = $chapter if (!$first && !$chapter->{skip});

        if (defined($name)) {
            return $chapter if (($chapter->{id} eq $name)
                            || ($chapter->{path} eq $name));
        } else {
            return $first if ($first);
        }
    }

    return $first;
}

# To implement in subclasses:
# _open() -> bool
# chapter(name_or_id) -> chapter

1;
