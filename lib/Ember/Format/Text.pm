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

=head2 Instance Methods

=over

=item format($input)

Format some plain text into an array of lines with a maximum length.

=cut

sub format {
    my ($self, $input) = @_;
    my $width = $self->{width};
    my $line = '';
    my $llen = 0;
    my @lines;

    foreach my $in (split(/\r?\n/, $input)) {
        my @words = split(/\s+/, $in);

        if (@words == 0) {
            if ($llen > 0) {
                push(@lines, $line);
                $line = '';
                $llen = 0;
            }

            push(@lines, '') if (@lines);
            next;
        }

        foreach my $word (@words) {
            my $wlen = length($word);

            if (($llen > 0) && (($llen + $wlen) >= $width)) {
                push(@lines, $line);
                $line = '';
                $llen = 0;
            }

            while ($wlen > $width) {
                push(@lines, substr($word, 0, $width, ''));
                $wlen -= $width;
            }

            if ($llen == 0) {
                $line = $word;
                $llen = $wlen;
            } else {
                $line .= ' ' . $word;
                $llen += 1 + $wlen;
            }
        }
    }

    push(@lines, $line) if ($llen > 0);
    pop(@lines) while (@lines && $lines[$#lines] eq '');

    return @lines;
}

=back

=head1 SEE ALSO

L<Ember::Format>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
