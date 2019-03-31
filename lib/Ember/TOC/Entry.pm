package Ember::TOC::Entry;

=head1 NAME

Ember::TOC::Entry - An entry in a Table of Contents.

=head1 DESCRIPTION

This class represents an entry in a Table of Contents.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( id chapter anchor title order );

=head2 Fields

=over

=item id

A unique id for the entry

=item chapter

The chapter ID for the entry.

=item anchor

An anchor point within the chapter.

=item title

The entry's title.

=item order

Display order for the entry.

=back

=head2 Class Methods

=over

=item new(\%entry)

Create a new entry.

=cut

sub new {
    my ($class, $entry) = @_;
    my $self = fields::new($class);

    foreach my $key (keys(%{$entry})) {
        $self->{$key} = $entry->{$key} if (defined($entry->{$key}));
    }

    return $self;
}

=back

=head1 SEE ALSO

L<Ember::TOC>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
