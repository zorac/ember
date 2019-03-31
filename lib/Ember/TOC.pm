package Ember::TOC;

=head1 NAME

Ember::TOC - Table of Contents handling.

=head1 DESCRIPTION

This class handles tables of contents.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( entries );

=head2 Fields

=over

=item entries

The top-level entries in the table of contents.

=back

=head2 Class Methods

=over

=item new(\@entries)

Create a new table of contents.

=cut

sub new {
    my ($class, $entries) = @_;
    my $self = fields::new($class);

    $self->{entries} = $entries || [];

    return $self;
}

=back

=head2 Instance Methods

=over

=item root_entries()

Return an array of root entries.

=cut

sub root_entries {
    my ($self) = @_;

    return @{$self->{entries}};
}

=item all_entries()

Return an array of all entries.

=cut

sub all_entries {
    my ($self) = @_;
    my @entries = @{$self->{entries}};

    for (my $i = 0; $i < @entries; $i++) {
        splice(@entries, $i + 1, 0, @{$entries[$i]{children}})
            if (defined($entries[$i]{children}));
    }

    return @entries;
}

=back

=head1 SEE ALSO

L<Ember::Book>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
