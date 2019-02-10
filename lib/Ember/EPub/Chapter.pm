#!/usr/bin/perl

package Ember::EPub::Chapter;

use strict;
use warnings;
use base qw( Ember::Chapter );

sub lines {
    my ($self, $width) = @_;
    my $book = $self->{book};
    my $path = $book->{rootpath} . $self->{path};
    my $content = $book->{vfs}->content($path);

    return $book->{formatter}->format($content, $width);
}

1;
