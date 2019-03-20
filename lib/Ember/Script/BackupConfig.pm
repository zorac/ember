package Ember::Script::BackupConfig;

=head1 NAME

Ember::Script::BackupConfig - Back up the Ember config

=head1 SYNOPSIS

use Ember::Script::BackupConfig;

my $ember = Ember::Script::BackupConfig->new(@ARGV);

$ember->run();

=head1 DESCRIPTION

Ember script to back up the config to JSON.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Script );

use JSON;

=head2 Instance Methods

=over

=item run()

Back up the config.

=cut

sub run {
    my ($self) = @_;
    my $json = JSON->new()->utf8()->indent()->space_after();

    print $json->encode($self->{config}->{db});
}

=back

=head1 SEE ALSO

L<ember>, L<Ember::Config>, L<Ember::Script>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
