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

=over @FIELDS

Defines the metadata fields which Ember supports. Each entry is an array of
[ $field, $display_name, $hint ]. Possible values for the hint are 'text',
'array', 'hash', 'hide' and 'multi.

=cut

our @FIELDS = (
    [ title         => 'Title',         'text'  ],
    [ title_sort    => 'Title Sort',    'hide'  ],
    [ authors       => 'Author',        'array' ],
    [ author_sort   => 'Author Sort',   'hide'  ],
    [ series        => 'Series',        'text'  ],
    [ series_index  => 'In Series',     'text'  ],
    [ publisher     => 'Publisher',     'text'  ],
    [ date          => 'Date',          'text'  ],
    [ copyright     => 'Copyright',     'text'  ],
    [ language      => 'Language',      'text'  ],
    [ generator     => 'Generator',     'text'  ],
    [ ids           => 'IDs',           'hash'  ],
    [ description   => 'Description',   'multi' ],
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

    foreach my $row (@FIELDS) {
        my ($key, $name, $hint) = @{$row};
        my $value = $self->{$key};

        next if (!$value || ($hint eq 'hide'));

        if ($hint eq 'array') {
            $name .= 's' if (@{$value} > 1);
            push(@meta, [ $name, $value->[0] ]);

            for (my $i = 1; $i < @{$value}; $i++) {
                push(@meta, [ '', $value->[$i] ]);
            }
        } elsif ($hint eq 'hash') {
            foreach my $hkey (sort(keys(%{$value}))) {
                push(@meta, [ $hkey, $value->{$hkey} ]);
            }
        } elsif ($hint eq 'multi') {
            push(@meta, [ undef, $value ]);
        } else {
            push(@meta, [ $name, $value ]);
        }
    }

    return @meta;
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
