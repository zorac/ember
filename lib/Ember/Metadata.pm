package Ember::Metadata;

=head1 NAME

Ember::Metadata - Metadata handling.

=head1 DESCRIPTION

This class handles book metadata.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( title title_sort authors author_sort series series_index
    publisher date copyright language generator ids description );

=head2 Constants

=over

=item @FIELDS

Defines the metadata fields which Ember supports.

=cut

our @FIELDS = qw(
    title
    title_sort
    authors
    author_sort
    series
    series_index
    publisher
    date
    copyright
    language
    generator
    ids
    description
);

=item @FIELDS

Speifies the human-readable names for metadata fields.

=cut

our %NAMES = (
    title           => 'Title',
    title_sort      => 'Title Sort',
    authors         => 'Author',
    author_sort     => 'Author Sort',
    series          => 'Series',
    series_index    => 'In Series',
    publisher       => 'Publisher',
    date            => 'Date',
    copyright       => 'Copyright',
    language        => 'Language',
    generator       => 'Generator',
    ids             => 'IDs',
    description     => 'Description',
);

=item %TYPES

Specifies the types for a metadataa field: 'text', 'array', 'hash', 'hide' and
'multi'.

=cut

our %TYPES = (
    title           => 'text',
    title_sort      => 'hide',
    authors         => 'array',
    author_sort     => 'hide',
    series          => 'text',
    series_index    => 'text',
    publisher       => 'text',
    date            => 'text',
    copyright       => 'text',
    language        => 'text',
    generator       => 'text',
    ids             => 'hash',
    description     => 'multi',
);

=back

=head2 Fields

=over

=item title

The book's title.

=item title_sort

A variant of the book's title used for determining sort order.

=item authors

An array containing the book's author(s).

=item author_sort

A single string of the book's author(s) used for determining sort order.

=item series

The name of a series the book belongs to.

=item series_index

The index of the book within its series (this is I<not> restircted to integers.)

=item publisher

The name of the book's publisher.

=item date

The date, possibly of publication, of the book.

=item copyright

A copyright string for the book.

=item language

A language code for the book.

=item generator

The name of the software used to generate the eBook.

=item ids

A hash of IDs related to the book.

=item description

A free-text description of the book.

=back

=head2 Class Methods

=over

=item new()

Create a new metadata object.

=cut

sub new {
    my ($class) = @_;
    my $self = fields::new($class);

    return $self;
}

=back

=head2 Instance Methods

=over

=item display()

Format this metadata for display in a table.
Returns ( [ 'Key' => 'Value' ] ... ). Blank keys indicate additional values for
the previous key. An undefined key indicates a long description field to be
displayed outside the table (there will be at most one, and it will always be
the last entry.)

=cut

sub display {
    my ($self) = @_;
    my @meta;

    foreach my $field (@FIELDS) {
        my $name = $NAMES{$field};
        my $type = $TYPES{$field};
        my $value = $self->{$field};

        next if (!$value || ($type eq 'hide'));

        if ($type eq 'array') {
            $name .= 's' if (@{$value} > 1);
            push(@meta, [ $name, $value->[0] ]);

            for (my $i = 1; $i < @{$value}; $i++) {
                push(@meta, [ '', $value->[$i] ]);
            }
        } elsif ($type eq 'hash') {
            foreach my $key (sort(keys(%{$value}))) {
                my $hval = $value->{$key};

                push(@meta, [ $key, $hval ])
                    if (defined($hval) && ($hval ne ''));
            }
        } elsif ($type eq 'multi') {
            push(@meta, [ undef, $value ]);
        } else {
            push(@meta, [ $name, $value ]);
        }
    }

    return @meta;
}

=item search_terms()

Fetch the search terms for this metadata.

=cut

sub search_terms {
    my ($self) = @_;
    my @terms;

    if (defined($self->{authors})) {
        foreach my $author (@{$self->{authors}}) {
            push(@terms, split(/[^A-Za-z]+/, $author));
        }
    }

    push(@terms, split(/[^A-Za-z]+/, $self->{title}))
        if (defined($self->{title}));

    push(@terms, split(/[^A-Za-z]+/, $self->{series}))
        if (defined($self->{series}));

    return @terms;
}

=back

=head1 SEE ALSO

L<Ember::Book>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
