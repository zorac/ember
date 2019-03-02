package Ember::VFS::Zip;

=head1 NAME

Ember::VFS::Zip - Virtual filesystem layer for zip archives.

=head1 DESCRIPTION

This VFS implementation exposes the contents of a zip archive.

=cut

use 5.008;
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

=head2 Class Methods

=over

=item new($filename)

Create a new VFS from a zip file, and enumerate its members. Returns undefined
if the specified file is not a zip archive.

=cut

sub new {
    my ($class, $filename) = @_;

    return undef if (!-f $filename);

    my $self = $class->SUPER::new($filename);

    eval {
        my $zip = Archive::Zip->new($filename);
        my %members;

        foreach my $member ($zip->memberNames()) {
            $members{$member} = 1;
        }

        $self->{zip} = $zip;
        $self->{members} = \%members;
    };

    return $self->{members} ? $self : undef;
}

=back

=head2 Instance Methods

=over

=item read_text($path)

Fetches the content of the zip archive member at the given path.

=cut

sub read_text {
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
