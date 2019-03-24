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
use fields qw( config screen width height footer );

use Carp;

=head2 Fields

=over

=item screen

The L<Ember::Config> instance this app should use.

=item screen

The L<Term::ANSIScreen> object this app should be displayed within.

=item width

The screen width, in characters.

=item height

The screen height, in characters.

=item footer

Persistent footer text, if any.


=back

=head2 Class Methods

=over

=item new($args)

Create a new app. Should be called on a concrete subclass to get a usable app.
Settable fields: config, screen (both required).

=cut

sub new {
    my ($class, $args) = @_;
    my $self = fields::new($class);

    $self->{config} = $args->{config};
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
    my $wchange = 0;
    my $hchange = 0;

    if ($width != $self->{width}) {
        $self->{width} = $width;
        $wchange = 1;
    }

    if ($height != $self->{height}) {
        $self->{height} = $height;
        $hchange = 1;
    }

    $self->layout($wchange, $hchange) if ($wchange || $hchange);
    $self->render();
}

=item layout($width_changed, $height_changed)

Layout the screen for initial display, or after a resize. To be implemented by
subclasses.

=cut

sub layout {
    my ($self, $width_changed, $height_changed) = @_;

    croak(ref($self) . ' has not implemented layout()');
}

=item render()

Render the app to the screen. To be implemented by subclasses.

=cut

sub render {
    my ($self) = @_;

    croak(ref($self) . ' has not implemented render()');
}

=item footer([ $text [, $persist [, $default ] ] ])

Display the given text in the footer, or the default footer if empty/undefined.
If the persist flag is set, the text should be kept until the persist flag is
explicitly set off. The default value should normally only be set by subclasses.

=cut

sub footer() {
    my ($self, $text, $persist, $default) = @_;

    if ($persist) {
        $self->{footer} = $text;
    } elsif (defined($persist)) {
        $self->{footer} = undef;
    }

    if (!defined($text)) {
        if (defined($self->{footer})) {
            $text = $self->{footer};
        } else {
            $text = defined($default) ? $default : '--';
        }
    }

    $self->{screen}->move_to(0, $self->{height} - 1);
    printf('%-' . $self->{width} . 's', $text);
    STDOUT->flush();
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
    } elsif (($key eq 'q') || ($key eq 'esc')) {
        return 'pop';
    } elsif ($key eq 'h') {
        return 'push', 'Help', { app => $self };
    }
}

=item command($command, @args)

Receive a command from another app.

=cut

sub command {
    my ($self, $command, @args) = @_;

    # No global commands defined
}

=item help_text()

Return any helpful text for the application.

=cut

sub help_text {
    my ($self) = @_;

    return undef; # No global help text defined
}

=item help_keys()

Return help on the supported keypresses for the application.

=cut

sub help_keys {
    my ($self) = @_;

    return [
        [ 'Escape, Q' => 'Go back to the previous screen, or quit Ember' ],
        [ R => 'Refresh the screen' ],
        [ H => 'Display this help' ],
    ];
}

=item close()

Signals that this app is to be closed and should save its state.

=cut

sub close {
    my ($self) = @_;

    # Does nothing
}

=back

=head1 SEE ALSO

L<Ember>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
