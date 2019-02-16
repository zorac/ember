package Ember::App;

=head1 NAME

Ember::App - An app within Ember, such as a book reader.

=head1 DESCRIPTION

This is an abstract superclass for apps. An app is something which renders
screens within Ember, and accepts input via keypresses.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( height screen width );

use Carp;

=head2 Fields

=over

=item height

The screen height, in characters.

=item screen

The Term::ANSIScreen object this app should be displayed within.

=item width

The screen width, in characters.

=back

=head2 Class Methods

=over

=item new($args)

Create a new app. Should be called on a concrete subclass to get a usable app.
Settable fields: screen (required).

=cut

sub new {
    my ($class, $args) = @_;
    my $self = fields::new($class);

    $self->{screen} = $args->{screen};
    $self->{width} = 0;
    $self->{height} = 0;

    return $self;
}

=back

=head2 Instance Methods

=over

=item display($width, $height)

Display the app within the screen.

=cut

sub display {
    my ($self, $width, $height) = @_;
    my $resized = 0;

    if ($width != $self->{width}) {
        $self->{width} = $width;
        $resized = 1;
    }

    if ($height != $self->{height}) {
        $self->{height} = $height;
        $resized = 1;
    }

    $self->layout if ($resized);
    $self->render;
}

=item layout()

Layout the screen for initial display, or after a resize. To be implemented by
subclasses.

=cut

sub layout {
    croak('Sub-class has not implemented layout()');
}

=item render()

Render the app to the screen. To be implemented by subclasses.

=cut

sub render {
    croak('Sub-class has not implemented render()');
}

=item keypress($key)

Handle a keypress; may return a command and optional argument. This class
provides default refresh and quit handlers. All subclasses should ensure that
they delegate any un-handled keypresses to their superclass's method using:
    return $self->SUPER::keypress($key);

=cut

sub keypress {
    my ($self, $key) = @_;

    if ($key eq 'r') {
        $self->render();
    } elsif ($key eq 'q') {
        return 'quit';
    }
}

=back

=head1 SEE ALSO

L<Ember>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
