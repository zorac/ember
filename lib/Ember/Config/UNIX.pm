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

=head2 Instance Methods

=over

=item _open()

Locate or create the Ember configuration directory within the current user's
home directory.

=cut

sub _open {
    my ($self) = @_;
    my $dir = $ENV{HOME} . '/.ember';

    mkdir($dir) unless (-d $dir);

    $self->{dir} = $dir;

    return 1;
}

=back

=head1 SEE ALSO

L<Ember::Config>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
