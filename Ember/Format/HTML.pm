#!/usr/bin/perl

package Ember::Format::HTML;

use strict;
use warnings;
use base qw( Ember::Format );

use HTML::FormatText;

sub format {
    my ($self, $input, $width) = @_;
    my $text = HTML::FormatText->format_string($input,
        lm => 0, rm => $width - 1);

    return split(/\r?\n/, $text);
}

1;
