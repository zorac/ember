package Ember::VFS::Zip;

=head1 NAME

Ember::VFS::Zip - Virtual filesystem layer for zip archives.

=head1 DESCRIPTION

This VFS implementation exposes the contents of a zip archive.

=cut

use strict;
use warnings;
use base qw( Ember::VFS );
use fields qw( zip members );

use Archive::Zip;

=head2 Fields

=over

=item zip

The underlying zip archive object.

=item members

Enumerates the members of the zip archive.

=back

=head2 Instance Methods

=over

=item _open()

Checks if the base filename is indeed a zip archive, and enumeates its members.

=cut

sub _open {
    my ($self) = @_;
    my $filename = $self->{filename};

    return 0 if (!-f $filename);

    eval {
        my $zip = Archive::Zip->new($filename);
        my %members;

        foreach my $member ($zip->memberNames()) {
            $members{$member} = 1;
        }

        $self->{zip} = $zip;
        $self->{members} = \%members;
    };

    return $self->{members} ? 1 : 0;
}

=item content($path)

Fetches the content of the zip archive member at the given path.

=cut

sub content {
    my ($self, $path) = @_;

    return unless ($self->{members}{$path});

    my $text = $self->{zip}->contents($path);

    utf8::decode($text);

    return $text;
}

=back

=head1 SEE ALSO

L<Ember::VFS>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
