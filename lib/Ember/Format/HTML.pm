package Ember::Format::HTML;

=head1 NAME

Ember::Format::HTML - HTML conversion and formatting.

=head1 DESCRIPTION

This class converts HTML files into plain text.

=cut

use strict;
use warnings;
use base qw( Ember::Format );

use HTML::FormatText;

=item lines($input, $width)

Format HTML text into an array of lines with a given maximum length.

=cut

sub format {
    my ($self, $input, $width) = @_;
    my $text = HTML::FormatText->format_string($input,
        lm => 0, rm => $width - 3);

    return split(/\r?\n/, $text);
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;