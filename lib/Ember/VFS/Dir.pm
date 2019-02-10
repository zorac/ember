package Ember::VFS::Dir;

=head1 NAME

Ember::VFS::Dir - Virtual filesystem layer for directories.

=head1 DESCRIPTION

This VFS implementation simply uses the contents of a real filesystem
directory.

=cut

use strict;
use warnings;
use base qw( Ember::VFS );

use File::Slurp;

=head2 Instance Methods

=over

=item _open()

Simply checks whether the base filname is indeed a directory.

=cut

sub _open {
    my ($self) = @_;

    return -d $self->{filename};
}

=item content($path)

Fetches the content of the given file within the base directory.

=cut

sub content {
    my ($self, $path) = @_;

    $path = $self->{filename} . '/' . $path;

    return unless (-f $path);
    return read_file($path, { binmode => ':utf8' });
}

=back

=head1 SEE ALSO

L<Ember::VFS>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;