package Ember::Config::UNIX;

=head1 NAME

Ember::Config::UNIX - Configuration handling for Ember on UNIX.

=head1 DESCRIPTION

This class handles configuration data for Ember on generic UNIX systems.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Config );

=head2 Class Methods

=over

=item new()

Create a configuration instance using a ".ember" directory in the user's home
directory.

=cut

sub new {
    my ($class) = @_;
    my $dir = $ENV{HOME} . '/.ember';

    mkdir($dir) unless (-d $dir);

    my $self = $class->SUPER::new($dir);

    return $self;
}

=back

=head1 SEE ALSO

L<Ember::Config>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
