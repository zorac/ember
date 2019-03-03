package Ember::Format::KeyValue;

=head1 NAME

Ember::Format::KeyValue - Formats a collection of keys and values for display.

=head1 DESCRIPTION

This formatter converts a collection of keys and values into a plain-text
table.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Format );

use Ember::Format::Text;

=head2 Instance Methods

=over

=item format($input)

Format into an array of lines with a maximum length. Input should be an array
in the format [ [ $key, $value ], ... ].

=cut

sub format {
    my ($self, $input) = @_;
    my $width = $self->{width};
    my $keywidth = 0;
    my @rows;

    foreach my $row (@{$input}) {
        my $len = length($row->[0]);
        $keywidth = $len if ($len > $keywidth);
    }

    if ($keywidth >= ($width / 3)) {
        my $format = Ember::Format::Text->new($width);

        foreach my $row (@{$input}) {
            push(@rows, $format->format($row->[0] . ':'));
            push(@rows, $format->format($row->[1]));
            push(@rows, '');
        }

        pop(@rows);
    } else {
        my $key_format = Ember::Format::Text->new($keywidth);
        my $value_format = Ember::Format::Text->new($width - ($keywidth + 2));
        my $fmta = '%' . $keywidth . 's: %s';
        my $fmtb = '%' . $keywidth . 's  %s';

        foreach my $row (@{$input}) {
            my @keys = $key_format->format($row->[0]);
            my @values = $value_format->format($row->[1]);
            my $count = (@keys > @values) ? @keys : @values;

            for (my $i = 0; $i < $count; $i++) {
                my $key = $keys[$i] || '';

                push(@rows, sprintf(($i || ($key eq '')) ? $fmtb : $fmta,
                    $key, $values[$i] || ''));
            }
        }
    }

    return @rows;
}

=back

=head1 SEE ALSO

L<Ember::Format>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
