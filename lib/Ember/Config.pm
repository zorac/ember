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
use fields qw( dir json );

use File::Slurp;
use JSON;

=head2 Fields

=over

=item dir

The configuration directory.

=item json

A JSON encoder/decoder.

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

    $self->{dir} = $dir;
    $self->{json} = JSON->new()->utf8()->indent()->space_after();

    return $self;
}

=item open()

Create and return a confifiguration instance of the appropriate
platform-specific subclass.

=cut

sub open {
    if ($^O eq 'darwin') {
        require Ember::Config::MacOS;
        return Ember::Config::MacOS->new();
    } elsif ($^O eq 'MSWin32') {
        require Ember::Config::Windows;
        return Ember::Config::Windows->new();
    } else {
        require Ember::Config::UNIX;
        return Ember::Config::UNIX->new();
    }
}

=back

=head2 Instance Methods

=over

=item read_json($name, $if_empty)

Read the contents of the given configuration file and return a reference.

=cut

sub read_json {
    my ($self, $name, $if_empty) = @_;
    my $path = $self->{dir} . '/' . $name . '.json';

    return $if_empty if (!-f $path);

    my $json = read_file($path, { binmode => ':utf8' });

    return $if_empty if (length($json) == 0);
    return $self->{json}->decode($json);
}

=item write_json($name, $content)

Write the input to a given configuration file.

=cut

sub write_json {
    my ($self, $name, $content) = @_;
    my $path = $self->{dir} . '/' . $name . '.json';
    my $json = $self->{json}->encode($content);

    # TODO error checking
    write_file($path, { binmode => ':utf8', atomic => 1 }, $json);
}

=item next_id($type)

Returns the next unique ID of the given type.

=cut

sub next_id {
    my ($self, $type) = @_;
    my $map = $self->read_json('last_ids', {});
    my $id = 1;

    if (exists($map->{$type})) {
        $id = ++$map->{$type};
    } else {
        $map->{$type} = 1;
    }

    $self->write_json('last_ids', $map);

    return $id;
}

=item get_id($filename)

Fetch the Ember ID for the book with the given filename.

=cut

sub get_id {
    my ($self, $filename) = @_;
    my $map = $self->read_json('file_to_id', {});
    my $id = $map->{$filename};

    if (!$id) {
        $id = $self->next_id('book');
        $map->{$filename} = $id;
        $self->write_json('file_to_id', $map);
    }

    return $id;
}

=item get_pos($book)

Fetch the last chapter and reading position for a given eBook.

=cut

sub get_pos {
    my ($self, $book) = @_;
    my $map = $self->read_json('positions', {});

    return exists($map->{$book}) ? @{$map->{$book}} : ();
}

=item save_pos($book, $chapter, $pos)

Save the last reading position for a book.

=cut

sub save_pos {
    my ($self, $book, $chapter, $pos) = @_;
    my $map = $self->read_json('positions', {});

    $map->{$book} = [ $chapter, $pos ];
    $self->write_json('positions', $map);
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
