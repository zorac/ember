package Ember::Format;

=head1 NAME

Ember::Format - Text conversion and formatting.

=head1 DESCRIPTION

Abstract superclass for objects which convert raw eBook data into formatted
text for CLI display.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( width );

use Carp;

=head2 Fields

=over

=item width

The width text should be formatted to fit in.

=back

=head2 Class Methods

=over

=item new($width)

Create a new formatter for a given screen width in characters. You should call
this directly on a subclass if you want an object which is actually useful.

=cut

sub new {
    my ($class, $width) = @_;
    my $self = fields::new($class);

    $self->{width} = $width;

    return $self;
}

=back

=head2 Instance Methods

=over

=item format($input)

Must be implemented by sub-classes to format text lines for the given input.

=cut

sub format {
    my ($self, $input) = @_;

    croak(ref($self) . ' has not implemented format()');
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
