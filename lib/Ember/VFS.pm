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

use Ember::Util;

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

=item content($path)

Must be implemented by sub-classes to fetch the file content at a given path
within the virtual filesystem.

=cut

sub content {
    croak('Sub-class has not implemented content()');
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
