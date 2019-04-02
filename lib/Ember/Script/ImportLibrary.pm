package Ember::Script::ImportLibrary;

=head1 NAME

Ember::Script::ImportLibrary - Import an eBook library into Ember's config.

=head1 SYNOPSIS

use Ember::Script::ImportLibrary;

my $ember = Ember::Script::ImportLibrary->new(@ARGV);

$ember->run();

=head1 DESCRIPTION

Ember script to import a library of eBooks.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Script );
use fields qw( path );

use Carp;
use Cwd qw( realpath );
use File::Spec;

use Ember::Book;
use Ember::Metadata::OPF;
use Ember::Util;

=head2 Fields

=over

=item path

Path to the library to import.

=back

=head2 Class Methods

=over

=item new($args)

Create a new script object by passing an L<Ember::Args> object.

=cut

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    my $path = realpath($args->{import});

    croak("Library not found: $path") if (!-e $path);
    $self->{path} = $path;

    return $self;
}

=back

=head2 Instance Methods

=over

=item run()

Display the version

=cut

sub run {
    my ($self) = @_;
    my $path = $self->{path};

    if (-d $path) {
        if (-f File::Spec->join($path, 'metadata.db')) {
            $self->import_calibre($path);
        } else {
            $self->import_directory($path);
        }
    } else {
        croak("Don't know how to handle library file: $path");
    }
}

=item import_directory()

Recursively import a directory of eBooks.

=cut

sub import_directory {
    my ($self, $path) = @_;
    my $config = $self->{config};

    opendir(my $dir, $path);

    while (my $file = readdir($dir)) {
        next if ($file =~ /^\.\.?$/);

        my $filename = File::Spec->join($path, $file);

        if (eval { Ember::Book->open($filename, $config) }) {
            print "Added $filename\n";
        } elsif ($@ !~ /^Unable to determine format/) {
            print "Failed to add $filename\n";
        } elsif (-d $filename) {
            $self->import_directory($filename);
        }
    }
}

=item import_calibre()

Import something that looks like a Calibre library.

=cut

sub import_calibre {
    my ($self, $path) = @_;
    my $config = $self->{config};

    opendir(my $calibre_dir, $path);

    while (my $author = readdir($calibre_dir)) {
        next if ($author =~ /^\./);

        my $author_path = File::Spec->join($path, $author);

        next unless (-d $author_path);

        opendir(my $author_dir, $author_path);

        while (my $book = readdir($author_dir)) {
            next if ($book =~ /^\./);

            my $book_path = File::Spec->join($author_path, $book);
            my ($book_file, $metadata_file);

            next unless (-d $book_path);

            opendir(my $book_dir, $book_path);

            while (my $file = readdir($book_dir)) {
                if ($file =~ /\.epub$/) { # TODO other types
                    $book_file = File::Spec->join($book_path, $file);
                } elsif ($file eq 'metadata.opf') {
                    $metadata_file = File::Spec->join($book_path, $file);
                }
            }

            closedir($book_dir);

            if ($book_file && $metadata_file) {
                print "Adding $book_file...\n";

                my $id = $config->get_id($book_file);
                my $opf = xml_decode_file($metadata_file);
                my $metadata = Ember::Metadata::OPF->new($opf);

                $config->set_metadata($id, $metadata);
            }
        }

        closedir($author_dir);
    }

    closedir($calibre_dir);
}

=back

=head1 SEE ALSO

L<ember>, L<Ember>, L<Ember::Script>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
