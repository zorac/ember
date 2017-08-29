#!/usr/bin/perl

package Ember::Format;

use strict;
use warnings;
use fields;

sub new {
    my ($self, $filename) = @_;

    $self = fields::new($self) unless (ref($self));

    return $self;
}

# To implement in subclasses:
# format($input, $width) -> @lines

1;
