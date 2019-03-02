package Ember::Format::HTML;

=head1 NAME

Ember::Format::HTML - HTML conversion and formatting.

=head1 DESCRIPTION

This formatter converts HTML files into plain text.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Format );

use HTML::FormatText;

=head2 Instance Methods

=over

=item format($width, $input)

Format HTML text into an array of lines with a given maximum length.

=cut

sub format {
    my ($self, $width, $input) = @_;
    my $text = HTML::FormatText->format_string($input,
        lm => 0, rm => $width - 3);

    return split(/\r?\n/, $text);
}

=back

=head1 SEE ALSO

L<Ember::Format>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
