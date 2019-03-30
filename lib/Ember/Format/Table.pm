package Ember::Format::Table;

=head1 NAME

Ember::Format::Table - Formats a table of data for display.

=head1 DESCRIPTION

This format converts some data into a plain-text table.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Format );

use List::Util qw( sum );
use POSIX qw( floor );

use Ember::Format::Text;

=head2 Instance Methods

=over

=item lines($input)

Format into an array of lines with a maximum length. Input should be a
two-dimensional array of the data to display.

=cut

sub lines {
    my ($self, $input) = @_;
    my $width = $self->{width};

    return if (!@{$input});

    my $columns = @{$input->[1]};
    my @max_widths;

    return if (!$columns);
    $width = 1 + $width - $columns;
    return if ($width < $columns);

    foreach my $row (@{$input}) {
        for (my $i = 0; $i < $columns; $i++) {
            my $w = length($row->[$i]);

            $max_widths[$i] = $w
                if (!$max_widths[$i] || ($w > $max_widths[$i]));
        }
    }

    my $total_max = sum(@max_widths);
    my @widths;

    if ($total_max <= $width) {
        @widths = @max_widths;
    } else {
        my $multiplier = $width / $total_max;

        @widths = map { floor($_ * $multiplier) } @max_widths;
        # TODO use up fractional amounts, avoid zero-widths
    }

    my $format = join(' ', map { '%-' . $_ . '.' . $_ . 's' } @widths);

    return map { sprintf($format, @{$_}) } @{$input};
}

=back

=head1 SEE ALSO

L<Ember::Format>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
