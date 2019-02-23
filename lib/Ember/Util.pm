package Ember::Util;

=head1 NAME

Ember::Util - Utility functions for Ember.

=head1 DESCRIPTION

This class contains utility functions used by various other classes.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Exporter );

our @EXPORT = qw( get_class );

=head2 Exported Methods

=over

=item get_class($type, $name)

Fetch the Ember class with the given type and name, loading the module if
needed.

=cut

sub get_class {
    my ($type, $name) = @_;

    require 'Ember/' . $type . '/' . $name . '.pm';
    return 'Ember::' . $type . '::' . $name;
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
