package Ember::Config::MacOS;

=head1 NAME

Ember::Config::MacOS - Configuration handling for Ember on macOS.

=head1 DESCRIPTION

This class handles configuration data for Ember on Apple macOS.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Config );

use Carp;

=head2 Class Methods

=over

=item new()

Create a configuration instance using a directory in the user's "Application
Support" folder directory.

=cut

sub new {
    my ($class) = @_;
    my $appsupport = $ENV{HOME} . '/Library/Application Support';
    my $dir = $appsupport . '/Ember';

    croak('Failed to locate Application Support folder')
        unless (-d $appsupport);
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
