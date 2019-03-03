package Ember::Script::Help;

=head1 NAME

Ember::Script::Help - Output help text for Ember.

=head1 SYNOPSIS

use Ember::Script::Help;

my $ember = Ember::Script::Help->new(@ARGV);

$ember->run();

=head1 DESCRIPTION

Ember script to output some helpful text.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Script );

use Pod::Simple::Text;

=head2 Instance Methods

=over

=item run()

Display the version

=cut

sub run {
    my ($self) = @_;

    Pod::Simple::Text->filter($0);
}

=back

=head1 SEE ALSO

L<ember>, L<Ember>, L<Ember::Script>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
