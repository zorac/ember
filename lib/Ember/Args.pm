package Ember::Args;

=head1 NAME

Ember::Args - Argument parser for Ember.

=head1 SYNOPSIS

use Ember::Args;

my $args = Ember::Args->new(@ARGV);

=head1 DESCRIPTION

This class is the entrypoint for the Ember application.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( book );

use Getopt::Long;

=head2 Fields

=over

=item book

The filename of a book.

=back

=head2 Class Methods

=over

=item new()

Parse command line arguments and make them available.

=cut

sub new {
    my ($class, @args) = @_;
    my $self = fields::new($class);
    my $parser = Getopt::Long::Parser->new();

    $parser->getoptionsfromarray(\@args, $self, 'book=s');
    $self->{book} = $args[0] if (@args && !defined($self->{book}));

    return $self;
}

=back

=head1 SEE ALSO

L<ember>, L<Ember>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
