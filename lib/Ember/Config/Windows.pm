package Ember::Config::Windows;

=head1 NAME

Ember::Config::Windows - Configuration handling for Ember on Windows.

=head1 DESCRIPTION

This class handles configuration data for Ember on Microsoft Windows.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Config );

use Carp;

=head2 Class Methods

=over

=item new()

Create a configuration instance using a directory... somewhere.

=cut

sub new {
    croak('Windows is not yet supported.')
}

=back

=head1 SEE ALSO

L<Ember::Config>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
