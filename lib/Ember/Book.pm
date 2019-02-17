package Ember::Book;

=head1 NAME

Ember::Book - An eBook.

=head1 SYNOPSIS

use Ember::Book;

my $book = Ember::Book->open($vfs);

=head1 DESCRIPTION

This is an abstract superclass for objects which handle opening eBooks and
retrieving their chapters and other details.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( filename vfs metadata chapters );

use Carp;

use Ember::VFS;

our @METADATA = (
    [ title         => 'Title',         ''      ],
    [ title_sort    => 'Title Sort',    'hide'  ],
    [ authors       => 'Author',        'array' ],
    [ author_sort   => 'Author Sort',   'hide'  ],
    [ series        => 'Series',        ''      ],
    [ series_index  => 'In Series',     ''      ],
    [ publisher     => 'Publisher',     ''      ],
    [ date          => 'Date',          ''      ],
    [ copyright     => 'Copyright',     ''      ],
    [ language      => 'Language',      ''      ],
    [ generator     => 'Generator',     ''      ],
    [ ids           => 'IDs',           'hash'  ],
    [ description   => 'Description',   'multi' ],
);

our %HINTS = (
    epub    => 'EPUB',
);

=head2 Fields

=over

=item filename

The filename for this book.

=item vfs

The L<Ember::VFS> instance providing the data for this book.

=item metadata

Metadata about this book.

=item chapters

An array of L<Ember::Chapter> objects contained within this book.

=back

=head2 Class Methods

=over

=item new($vfs)

Create a new Book instance with data from a supplied VFS instance. Useless
unless called an a concrete subclass. Normally, you should simply use the
open() method to detect the correct format.

=cut

sub new {
    my ($class, $vfs) = @_;
    my $self = fields::new($class);

    $self->{vfs} = $vfs;
    $self->{filename} = $vfs->{filename};
    $self->{metadata} = {};
    $self->{chapters} = [];

    return $self;
}

=item open($vfs)

Open a book from a given VFS instance. This will attempt to detected the file
format and generate an object of the required subclass.

=cut

sub open {
    my ($class, $vfs) = @_;

    $vfs = Ember::VFS->open($vfs) if (!$vfs->isa('Ember::VFS'));

    if (1) {
        require Ember::EPUB::Book;
        return Ember::EPUB::Book->new($vfs);
    }

    # TODO support other formats

    croak('Unable to determine format');
}

=back

=head2 Instance Methods

=over

=item chapter([$name_or_id])

Fetch a chapter object by name or ID, or the first readable chapter.

Subclasses may wish to override this method.

=cut

sub chapter {
    my ($self, $name) = @_;
    my $first;

    foreach my $chapter (@{$self->{chapters}}) {
        $first = $chapter if (!$first && !$chapter->{skip});

        if (defined($name)) {
            return $chapter if (($chapter->{id} eq $name)
                            || ($chapter->{path} eq $name));
        } else {
            return $first if ($first);
        }
    }

    return $first;
}

=back

=head1 SEE ALSO

L<Ember::Chapter>, L<Ember::VFS>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
