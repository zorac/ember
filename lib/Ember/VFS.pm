package Ember::VFS;

=head1 NAME

Ember::VFS - Virtual filesystem layer for Ember.

=head1 SYNOPSIS

use Ember::VFS;

my $vfs = Ember::VFS->open($filename);

=head1 DESCRIPTION

This is the base class for Ember's virtual filesystem layer.

=cut

use strict;
use warnings;
use fields qw( filename );

my %HINTS = (
    epub    => 'Zip',
    zip     => 'Zip',
);

=head2 Fields

=over

=item filename

The base file or directory name.

=back

=head2 Class Methods

=over

=item new($filename)

Create a new virtual filesystem from a given file or directory. Will fail if
not called on a subclass; instead use the open() method to automatically create
the correct object.

=cut

sub new {
    my ($self, $filename) = @_;

    $self = fields::new($self) unless (ref($self));
    $self->{filename} = $filename;

    return $self if ($self->_open());
}

=item open($filename)

Create and return a VFS instance of the appropriate subclass for the given file
or directory name.

=cut

sub open {
    my ($class, $filename) = @_;

    if (-d $filename) {
        require Ember::VFS::Dir;
        return Ember::VFS::Dir->new($filename)
    } else {
        require Ember::VFS::Zip;
        return Ember::VFS::Zip->new($filename);
    }

    # TODO use hints, check all...

    die('Unable to determine VFS type')
}

=back

=head2 Instance Methods

=over

=item _open()

Subclasses must implement this to open the file or directory. Should return a
true value on success.

=cut

sub _open {
    die('Cannot directly instantiate Ember::VFS');
}

=item content($path)

Must be implemented by sub-classes to fetch the file content at a given path
within the virtual filesystem.

=cut

sub content {
    die('Sub-class has not implemented content()');
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
