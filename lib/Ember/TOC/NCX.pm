package Ember::TOC::NCX;

=head1 NAME

Ember::TOC::NCX - NCX format table of Contents handling.

=head1 DESCRIPTION

This class handles NCX format tables of contents.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::TOC );

use Ember::TOC::Entry;

=head2 Class Methods

=over

=item new($ncx)

Create a new table of contents from parsed NCX XML.

=cut

sub new {
    my ($class, $ncx) = @_;
    my @entries;

    foreach my $nav (@{$ncx->{navMap}[0]{navPoint}}) {
        my ($chapter, $anchor) = split(/#/, $nav->{content}[0]{src});

        push(@entries, Ember::TOC::Entry->new({
            id      => $nav->{id},
            chapter => $chapter,
            anchor  => $anchor,
            title   => $nav->{navLabel}[0]{text}[0]{_},
            order   => $nav->{playOrder},
        }));
        # TODO nested
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
