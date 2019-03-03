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
use fields qw( book dump help version width );

use Getopt::Long;

=head2 Fields

=over

=item book

The filename of a book to read.

=item dump

The filename of a book to dump.

=item help

If set, display help for Ember, then exit.

=item version

If set, display the version of Ember, then exit.

=item width

The width, in characters, of the dump output.

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

    exit(1) unless $parser->getoptionsfromarray(\@args, $self,
        'book|b=s',
        'dump|d=s',
        'help|h',
        'version|v',
        'width|w=i',
    );

    # Fallback for calling with no options
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
