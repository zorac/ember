package Ember::TOC;

=head1 NAME

Ember::TOC - Table of Contents handling.

=head1 DESCRIPTION

This class handles tables of contents.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( entries );

=head2 Fields

=over

=item entries

The top-level entries in the table of contents.

=back

=head2 Class Methods

=over

=item new(\@entries)

Create a new table of contents.

=cut

sub new {
    my ($class, $entries) = @_;
    my $self = fields::new($class);

    $self->{entries} = $entries || [];

    return $self;
}

=back

=head2 Instance Methods

=over

=back

=head1 SEE ALSO

L<Ember::Book>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
