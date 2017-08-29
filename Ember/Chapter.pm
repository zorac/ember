#!/usr/bin/perl

package Ember::Chapter;

use strict;
use warnings;
use fields qw( id path mime skip book prev next );

sub new {
    my ($self) = @_;

    $self = fields::new($self) unless (ref($self));

    return $self;
}

# To implement in subclasses:
# lines($width) -> @lines

1;
