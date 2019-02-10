#!/usr/bin/perl

package Ember::Book;

use strict;
use warnings;
use fields qw( filename fs chapters );

# TODO dynamic format loading
use Ember::EPub::Book;
use Ember::FS;

my %HINTS = (
    epub    => 'EPub',
);

sub new {
    my ($self, $fs) = @_;
    my $filename = $fs->{filename};

    $self = fields::new($self) unless (ref($self));
    $self->{fs} = $fs;
    $self->{filename} = $filename;
    $self->{chapters} = [];

    return $self if ($self->_open());
}

sub open {
    my ($class, $fs) = @_;

    $fs = Ember::FS->open($fs) if (!$fs->isa('Ember::FS'));

    if (1) {
        return Ember::EPub::Book->new($fs);
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
