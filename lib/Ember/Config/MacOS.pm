package Ember::Config::MacOS;

=head1 NAME

Ember::Config::MacOS - Configuration handling for Ember on macOS.

=head1 DESCRIPTION

This class handles configuration data for Ember on Apple macOS.

=cut

use strict;
use warnings;
use base qw( Ember::Config );

=head2 Instance Methods

=over

=item _open()

Locate or create the Ember configuration directory within the current user's
Application Support directory.

=cut

sub _open {
    my ($self) = @_;
    my $appsupport = $ENV{HOME} . '/Library/Application Support';
    my $dir = $appsupport . '/Ember';

    die('Failed to locate Application Support folder') unless (-d $appsupport);
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
