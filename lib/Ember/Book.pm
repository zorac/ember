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
use fields qw( id filename vfs config metadata toc chapters is_new start );

use Carp;
use Cwd qw( realpath );
use File::Basename;

use Ember::Util qw( get_class );
use Ember::VFS;

=head2 Constants

=over

=item %EXTENSIONS

Mapping of file extensions to likely eBook formats.

=cut

our %EXTENSIONS = (
    epub    => 'EPUB',
    epub3   => 'EPUB',
    ibooks  => 'EPUB',
    kepub   => 'EPUB',
);

=back

=head2 Fields

=over

=item id

Ember's internal ID for the book.

=item filename

The filename for this book.

=item vfs

The L<Ember::VFS> instance providing the data for this book.

=item config

An L<Ember::Config> instance.

=item metadata

An L<Ember::Metadata> with details of this book.

=item toc

An L<Ember::TOC> with the table of contents of this book.

=item chapters

An array of L<Ember::Chapter> objects contained within this book.

=item is_new

True if this is the first time the book has been opened.

=item start

The starting position for rewading the book [ $chapter [, $anchor ] ].

=back

=head2 Class Methods

=over

=item new($args)

Create a new Book instance. Required args: 'vfs', 'config'. Useless unless
called an a concrete subclass. Normally, you should simply use the open()
method to detect the correct format.

=cut

sub new {
    my ($class, $args) = @_;
    my $self = fields::new($class);
    my $vfs = $args->{vfs};
    my $filename = $vfs->{filename};
    my $config = $args->{config};
    my ($id, $is_new) = $config->get_id($filename);

    $self->{config}     = $config;
    $self->{vfs}        = $vfs;
    $self->{id}         = $id;
    $self->{is_new}     = $is_new ? 1 : 0;
    $self->{filename}   = $filename;
    $self->{metadata}   = {};
    $self->{chapters}   = [];

    return $self;
}

=item open($filename, $config)

Open a book from a given filename. This will attempt to detected the file
format and generate an object of the required subclass.

=cut

sub open {
    my ($class, $filename, $config) = @_;

    $filename = realpath($filename);
    croak("File not found: $filename") unless (-e $filename);

    my ($ext) = ($filename =~ /^.+\.(.+?)$/);
    my $format = defined($ext) ? $EXTENSIONS{lc($ext)} : undef;
    # TODO support other formats

    croak('Unable to determine format') if (!defined($format));

    my $book_class = get_class($format, 'Book');
    my $vfs = Ember::VFS->open($filename);
    my $book = $book_class->new({ vfs => $vfs, config => $config });

    $book->load_external_metadata();
    $book->save_metadata() if ($book->{is_new}); # TODO always?

    return $book;
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

=item get_pos()

Fetch the current chapter, reading position, and anchor for this book.

=cut

sub get_pos {
    my ($self) = @_;
    my ($id, $pos) = $self->{config}->get_pos($self->{id});
    my $anchor;

    if (!$id && $self->{start}) {
        ($id, $anchor) = @{$self->{start}};
    }

    return $self->chapter($id), $pos || 0, $anchor;
}

=item save_pos($chapter, $pos)

Save the current chapter and position for this book, and add it to the recent
books list.

=cut

sub save_pos {
    my ($self, $chapter, $pos) = @_;
    my $config = $self->{config};
    my $id = $self->{id};

    $config->save_pos($id, $chapter->{path}, $pos); # TODO
    $config->add_recent($id);
}

=item load_external_metadata()

Check for external files which may contain metadata about the book, and if so
load it.

=cut

sub load_external_metadata {
    my ($self) = @_;
    my $vfs = Ember::VFS->open(dirname($self->{filename}));
    my $opf = $vfs->read_xml('metadata.opf');

    if ($opf) {
        my $class = get_class('Metadata', 'OPF');
        my $metadata = $class->new($opf);

        $self->{metadata} = $metadata; # TODO merge
    }
}

=item display_metadata()

Fetch display metadata for this book. Returns ( [ 'Key' => 'Value' ] ... ).

=cut

sub display_metadata {
    my ($self) = @_;

    return $self->{metadata}->display();
}

=item save_metadata()

Save metadata for this book to the configuration store.

=cut

sub save_metadata {
    my ($self) = @_;

    $self->{config}->set_metadata($self->{id}, $self->{metadata});
}

=back

=head1 SEE ALSO

L<Ember::Chapter>, L<Ember::VFS>, L<Ember::Metadata>, L<Ember::Config>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
