package Ember::Config;

=head1 NAME

Ember::Config - Configuration handling for Ember.

=head1 SYNOPSIS

use Ember::Config;

my $config = Ember::Config->open();

=head1 DESCRIPTION

This is an abstract superclass for objects which handle configuration data for
Ember.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( vfs );

use Ember::Util;
use Ember::VFS;

=head2 Fields

=over

=item vfs

An L<Ember::VFS> instance for the configuration directory.

=back

=head2 Class Methods

=over

=item new($dir)

Create a configuration instance using the given directory. Normally, you should
simply use the open() method to create a platform-specific instance.

=cut

sub new {
    my ($class, $dir) = @_;
    my $self = fields::new($class);

    $self->{vfs} = Ember::VFS->open($dir);

    return $self;
}

=item open()

Create and return a confifiguration instance of the appropriate
platform-specific subclass.

=cut

sub open {
    my ($class) = @_;
    my $os = 'UNIX';

    if ($^O eq 'darwin') {
        $os = 'MacOS';
    } elsif ($^O eq 'MSWin32') {
        $os = 'Windows';
    }

    $class = get_class('Config', $os);

    return $class->new();
}

=back

=head2 Instance Methods

=over

=item read_json($name, $if_empty)

Read the contents of the given configuration file and return a reference.

=cut

sub read_json {
    my ($self, $name, $if_empty) = @_;
    my $content = $self->{vfs}->read_json("$name.json");

    return defined($content) ? $content : $if_empty;
}

=item write_json($name, $content)

Write the input to a given configuration file.

=cut

sub write_json {
    my ($self, $name, $content) = @_;

    $self->{vfs}->write_json("$name.json", $content);
}

=item get_id($filename)

Fetch the Ember ID for the book with the given filename. In a list context, may
return a second value which indicates that the ID was newly created.

=cut

sub get_id {
    my ($self, $filename) = @_;
    my $to_id = $self->read_json('file_to_id', {});
    my $id = $to_id->{$filename};

    return $id if ($id);

    my $to_file = $self->read_json('id_to_file', [0]);

    $id = ++$to_file->[0];
    $to_id->{$filename} = $id;
    $to_file->[$id] = $filename;

    $self->write_json('file_to_id', $to_id);
    $self->write_json('id_to_file', $to_file);

    return wantarray ? ($id, 1) : $id;
}

=item get_filename($book_id)

Fetch the filename for a given Ember book ID.

=cut

sub get_filename {
    my ($self, $book_id) = @_;
    my $to_file = $self->read_json('id_to_file', []);

    return $to_file->[$book_id];
}

=item get_pos($book_id)

Fetch the last chapter and reading position for a given eBook.

=cut

sub get_pos {
    my ($self, $book_id) = @_;
    my $map = $self->read_json('positions', {});

    return exists($map->{$book_id}) ? @{$map->{$book_id}} : ();
}

=item save_pos($book_id, $chapter_id, $pos)

Save the last reading position for a book.

=cut

sub save_pos {
    my ($self, $book_id, $chapter_id, $pos) = @_;
    my $map = $self->read_json('positions', {});

    $map->{$book_id} = [ $chapter_id, $pos ];
    $self->write_json('positions', $map);
}

=item get_recent()

Fetch a list of recently-viewed books. Returns an array of arrays of timestamp
and book ID.

=cut

sub get_recent {
    my ($self) = @_;

    return $self->read_json('recent', []);
}

=item add_recent($book_id)

Add an entry for the given book to the recents list.

=cut

sub add_recent {
    my ($self, $book_id) = @_;
    my $recent = $self->read_json('recent', []);
    my $count = @{$recent};

    if (($count > 0) && ($recent->[0][1] == $book_id)) {
        $recent->[0][0] = time;
    } else {
        for (my $i = 1; $i < $count; $i++) {
            if ($recent->[$i][1] == $book_id) {
                splice(@{$recent}, $i, 1);
                last;
            }
        }

        unshift(@{$recent}, [ time, $book_id ]);
    }

    $self->write_json('recent', $recent);
}

=item get_metadata([ $book_id ])

Fetch metadata for a book, or for all books;

=cut

sub get_metadata {
    my ($self, $book_id) = @_;
    my $cache = $self->read_json('metadata', []);

    return $cache if (!$book_id);
    return $cache->{$book_id} if (exists($cache->[$book_id]));
    return {};
}

=item set_metadata($book_id, $metadata)

Set the metadata for a book.

=cut

sub set_metadata {
    my ($self, $book_id, $metadata) = @_;
    my $cache = $self->read_json('metadata', []);
    my %out;

    $out{title} = $metadata->{title} if (defined($metadata->{title}));
    $out{author} = join(', ', @{$metadata->{authors}})
        if (defined($metadata->{authors}));

    if (defined($metadata->{series})) {
        $out{series} = $metadata->{series};
        $out{index} = $metadata->{series_index}
            if (defined($metadata->{series_index}));
    }

    $cache->[$book_id] = \%out;
    $self->write_json('metadata', $cache);
}

=back

=head1 SEE ALSO

L<Ember::VFS>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
