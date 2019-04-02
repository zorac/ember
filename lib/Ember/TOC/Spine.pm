package Ember::TOC::Spine;

=head1 NAME

Ember::TOC::Spine - OPF spine format table of contents handling.

=head1 DESCRIPTION

This class handles OPF spine format tables of contents.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::TOC );

use Ember::TOC::Entry;

=head2 Class Methods

=over

=item new($spine)

Create a new table of contents from a parsed OPF spine.

=cut

sub new {
    my ($class, $spine) = @_;
    my $order = 1;
    my @entries;

    foreach my $ref (@{$spine->{itemref}}) {
        next if ($ref->{linear} && ($ref->{linear} eq 'no'));

        my $id = $ref->{idref};

        push(@entries, {
            id      => $id,
            chapter => $id,
            title   => $id,
            order   => $order++,
        });
    }

    return $class->SUPER::new(\@entries);
}

=back

=head1 SEE ALSO

L<Ember::TOC>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
