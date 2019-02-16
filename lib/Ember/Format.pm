package Ember::Format;

=head1 NAME

Ember::Format - Text conversion and formatting.

=head1 DESCRIPTION

Interface for converting raw eBook data into formatted text for CLI display.

=cut

use 5.008;
use strict;
use warnings;
use fields;

use Carp;

=head2 Class Methods

=over

=item new($filename)

Create a new formatter. You should call this directly on a subclass if you want
an object which is actually useful.

=cut

sub new {
    my ($class) = @_;
    my $self = fields::new($class);

    return $self;
}

=back

=head2 Instance Methods

=over

=item format($input, $width)

Must be implemented by sub-classes to format text lines for the given input,
restricted to a given display width in characters.

=cut

sub format {
    croak('Sub-class has not implemented format()');
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
