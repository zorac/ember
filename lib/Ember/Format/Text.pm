package Ember::Format::Text;

=head1 NAME

Ember::Format::Text - Text conversion and formatting.

=head1 DESCRIPTION

This formatter handles plain-text content. It assumes blank lines between
paragraphs.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Format );

use HTML::FormatText;

=head2 Instance Methods

=over

=item format($width, $input)

Format some plain text into an array of lines with a given maximum length.

=cut

sub format {
    my ($self, $width, $input) = @_;
    my $current = '';
    my $clen = 0;
    my @output;

    foreach my $line (split(/\r?\n/, $input)) {
        my @words = split(/\s+/, $line);

        if (@words == 0) {
            if ($clen > 0) {
                push(@output, $current);
                $current = '';
                $clen = 0;
            }

            push(@output, '') if (@output);
            next;
        }

        foreach my $word (@words) {
            my $wlen = length($word);

            if (($clen > 0) && (($clen + $wlen) >= $width)) {
                push(@output, $current);
                $current = '';
                $clen = 0;
            }

            while ($wlen > $width) {
                push(@output, substr($word, 0, $width, ''));
                $wlen -= $width;
            }

            if ($clen == 0) {
                $current = $word;
                $clen = $wlen;
            } else {
                $current .= ' ' . $word;
                $clen += 1 + $wlen;
            }
        }
    }

    if ($clen == 0) {
        pop(@output);
    } else {
        push(@output, $current);
    }

    return @output;
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
