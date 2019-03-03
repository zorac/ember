package Ember::Script::Version;

=head1 NAME

Ember::Script::Version - Output the version of Ember.

=head1 SYNOPSIS

use Ember::Script::Version;

my $ember = Ember::Script::Version->new(@ARGV);

$ember->run();

=head1 DESCRIPTION

Ember script to output the current version.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Script );

use Ember;

=head2 Instance Methods

=over

=item run()

Display the version

=cut

sub run {
    my ($self) = @_;

    print "Ember version $Ember::VERSION\n";
}

=back

=head1 SEE ALSO

L<ember>, L<Ember>, L<Ember::Script>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
