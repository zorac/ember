package Ember::Script;

=head1 NAME

Ember::Script - Abstract superclass for runnable scripts.

=head1 DESCRIPTION

Abstract superclass for runnable scripts.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( args config );

use Carp;

use Ember::Config;

=head2 Constants

=over

=item @FOR_ARG

Script to run based on the presence of an argument, in priority order.

=cut

our @FOR_ARG = (
    [ help          => 'Help'           ],
    [ version       => 'Version'        ],
    [ backup_config => 'BackupConfig'   ],
    [ dump          => 'Dump'           ],
    [ import        => 'ImportLibrary'  ],
);

=back

=head2 Fields

=over

=item args

The L<Ember::Args> object passed to this script.

=item config

An L<Ember::Config> instance.

=back

=head2 Class Methods

=over

=item new($args)

Create a new script object by passing an L<Ember::Args> object.

=cut

sub new {
    my ($class, $args) = @_;
    my $self = fields::new($class);

    $self->{args} = $args;
    $self->{config} = Ember::Config->open();

    return $self;
}

=back

=head2 Instance Methods

=over

=item run()

Run the script. Needs to be implemented by subclasses

=cut

sub run {
    my ($self) = @_;

    croak(ref($self) . ' has not implemented run()');
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
