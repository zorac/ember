package Ember::Format;

=head1 NAME

Ember::Format - Text conversion and formatting.

=head1 DESCRIPTION

Interface for converting raw eBook data into formatted text for CLI display.

=cut

use strict;
use warnings;
use fields;

sub new {
    my ($self) = @_;

    $self = fields::new($self) unless (ref($self));

    return $self;
}

=back

=head2 Instance Methods

=over

=item lines($input, $width)

Must be implemented by sub-classes to format text lines for the given input,
restricted to a given display width in characters.

=cut

sub lines {
    die('Sub-class has not implemented lines()');
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
