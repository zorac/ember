package Ember::Book;

=head1 NAME

Ember::Book - An eBook.

=head1 SYNOPSIS

use Ember::Book;

my $book = Ember::Book->open($vfs);

=head1 DESCRIPTION

This class handles opening eBooks and retrieving chapters and other details.

=cut

use strict;
use warnings;
use fields qw( filename vfs chapters );

use Ember::VFS;

my %HINTS = (
    epub    => 'EPub',
);

=head2 Fields

=over

=item filename

The filename for this book.

=item vfs

The L<Ember::VFS> instance providing the data for this book.

=item chapters

An array of L<Ember::Chapter> objects contained within this book.

=back

=head2 Class Methods

=over

=item new($vfs)

Create a new Book instance with data from a supplied VFS instance. Will fail if
called on this class directly, rathen than a subclass. Normally, you should
simply use the open() method to detect the correct format.

=cut

sub new {
    my ($self, $vfs) = @_;
    my $filename = $vfs->{filename};

    $self = fields::new($self) unless (ref($self));
    $self->{vfs} = $vfs;
    $self->{filename} = $filename;
    $self->{chapters} = [];

    return $self if ($self->_open());
}

=item open($vfs)

Open a book from a given VFS instance. This will attempt to detected the file
format and generate an object of the required subclass.

=cut

sub open {
    my ($class, $vfs) = @_;

    $vfs = Ember::VFS->open($vfs) if (!$vfs->isa('Ember::VFS'));

    if (1) {
        require Ember::EPub::Book;
        return Ember::EPub::Book->new($vfs);
    }

    # TODO support other formats

    die('Unable to determine format');
}

=back

=head2 Instance Methods

=over

=item _open()

Must be implemented by subclasses to open the book. Should return a true value
on success.

=cut

sub _open {
    die('Cannot directly instantiate Ember::Book');
}

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
