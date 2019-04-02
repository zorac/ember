package Ember::VFS::Dir;

=head1 NAME

Ember::VFS::Dir - Virtual filesystem layer for directories.

=head1 DESCRIPTION

This VFS implementation simply uses the contents of a real filesystem
directory.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::VFS );

use File::Slurp;
use File::Spec;

=head2 Class Methods

=over

=item new($filename)

Create a new VFS from a directory. Returns undefined if the specified path is
not a directory.

=cut

sub new {
    my ($class, $filename) = @_;

    return undef if (!-d $filename);

    my $self = $class->SUPER::new($filename);

    return $self;
}

=back

=head2 Instance Methods

=over

=item read_text($path)

Fetches the content of the given file within the base directory.

=cut

sub read_text {
    my ($self, $path) = @_;

    $path = File::Spec->join($self->{filename}, $path);

    return unless (-f $path);
    return scalar(read_file($path, { binmode => ':utf8' }));
}

=item write_text($path, $content)

Write the given content to the given file within the base directory.

=cut

sub write_text {
    my ($self, $path, $content) = @_;

    $path = File::Spec->join($self->{filename}, $path);

    write_file($path, { binmode => ':utf8', atomic => 1 }, $content);
}

=back

=head1 SEE ALSO

L<Ember::VFS>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
