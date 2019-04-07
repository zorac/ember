package Ember::VFS;

=head1 NAME

Ember::VFS - Virtual filesystem layer for Ember.

=head1 SYNOPSIS

use Ember::VFS;

my $vfs = Ember::VFS->open($filename);

=head1 DESCRIPTION

Abstract superclass for objects which provide a virtual filesystem to Ember.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( filename );

use Carp;

use Ember::Util qw( get_class json_parse json_generate xml_parse xml_generate );

=head2 Constants

=over

=item %HINTS

Mapping of file extensions to likely VFS types.

=cut

our %HINTS = (
    epub    => 'Zip',
    zip     => 'Zip',
);

=back

=head2 Fields

=over

=item filename

The base file or directory name.

=back

=head2 Class Methods

=over

=item new($filename)

Create a new virtual filesystem from a given file or directory. Ueseless unless
called on a concrete subclass. Normally, you should use the open() method to
automatically create the correct object.

=cut

sub new {
    my ($class, $filename) = @_;
    my $self = fields::new($class);

    $self->{filename} = $filename;

    return $self;
}

=item open($filename)

Create and return a VFS instance of the appropriate subclass for the given file
or directory name.

=cut

sub open {
    my ($class, $filename) = @_;
    my $type;

    if (-d $filename) {
        $type = 'Dir';
    } else {
        $type = 'Zip';
    }

    $class = get_class('VFS', $type);

    return $class->new($filename);

    # TODO use hints, check all...
    # croak('Unable to determine VFS type')
}

=back

=head2 Instance Methods

=over

=item read_text($path)

Must be implemented by sub-classes to fetch the file content at a given path
within the virtual filesystem. Returns undefined if the file does not exist.

=cut

sub read_text {
    my ($self, $path) = @_;

    croak(ref($self) . ' has not implemented read_text()');
}

=item write_text($path, $content)

May be implemented by sub-classes to allow writing file content at a given path
within the virtual filesystem.

=cut

sub write_text {
    my ($self, $path, $content) = @_;

    croak(ref($self) . ' has not implemented write_text()');
}

=item read_json($path)

Read the file at a given path, parse it as JSON, and return the parsed content.
Returns undefined if the file does not exist.

=cut

sub read_json {
    my ($self, $path) = @_;

    return json_parse($self->read_text($path));
}

=item write_json($path, $content)

Encode the given content as JSON and write it to a file at the given path.

=cut

sub write_json {
    my ($self, $path, $content) = @_;

    $self->write_text($path, json_generate($content));
}

=item read_xml($path)

Read the file at a given path, parse it as XML, and return the parsed content.
Returns undefined if the file does not exist.

=cut

sub read_xml {
    my ($self, $path) = @_;

    return xml_parse($self->read_text($path));
}

=item write_xml($path, $content)

Encode the given content as XML and write it to a file at the given path.

=cut

sub write_xml {
    my ($self, $path, $content) = @_;

    $self->write_text($path, xml_generate($content));
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
