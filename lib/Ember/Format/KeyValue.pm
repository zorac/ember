package Ember::Format::KeyValue;

=head1 NAME

Ember::Format::KeyValue - Formats a collection of keys and values for display.

=head1 DESCRIPTION

This formatter converts a colection of keys and values into a plain-text table.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Format );
use fields qw( splitter );

use Ember::Format::Text;

=head2 Class Methods

=over

=item new()

Create a new key/value formatter.

=cut

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new();

    $self->{splitter} = Ember::Format::Text->new();

    return $self;
}

=back

=head2 Instance Methods

=over

=item format($width, $input)

Format into an array of lines with a given maximum length. Input should be an
array in the format [ [ $key, $value ], ... ].

=cut

sub format {
    my ($self, $width, $input) = @_;
    my $splitter = $self->{splitter};
    my $keywidth = 0;
    my @rows;

    foreach my $row (@{$input}) {
        my $len = length($row->[0]);
        $keywidth = $len if ($len > $keywidth);
    }

    if ($keywidth >= ($width / 3)) {
        foreach my $row (@{$input}) {
            push(@rows, $splitter->format($width, $row->[0] . ':'));
            push(@rows, $splitter->format($width, $row->[1]));
            push(@rows, '');
        }

        pop(@rows);
    } else {
        my $valwidth = $width - ($keywidth + 2);
        my $fmta = '%' . $keywidth . 's: %s';
        my $fmtb = '%' . $keywidth . 's  %s';

        foreach my $row (@{$input}) {
            my @keys = $splitter->format($keywidth, $row->[0]);
            my @vals = $splitter->format($valwidth, $row->[1]);
            my $count = (@keys > @vals) ? @keys : @vals;

            for (my $i = 0; $i < $count; $i++) {
                my $key = $keys[$i] || '';

                push(@rows, sprintf(($i || ($key eq '')) ? $fmtb : $fmta,
                    $key, $vals[$i] || ''));
            }
        }
    }

    return @rows;
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
