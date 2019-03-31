package Ember::Screen;

=head1 NAME

Ember::Screen - Console screen management for Ember.

=head1 SYNOPSIS

use Ember::Screen;

my $screen = Ember::Screen->new();

=head1 DESCRIPTION

Provides screen management for Ember apps.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( termcap debug );

use Term::Cap;
use Term::ReadKey;

=head2 Constants

=over

=item %KEYMAP

Mapping of ASCII values to special key names.

=cut

our %KEYMAP = (
    27  => 'esc',
    127 => 'bs',
);

=back

=head2 Fields

=over

=item termcap

The Term::Cap object in use.

=item debug

Whether debug mode is enabled.

=back

=head2 Class Methods

=over

=item new($debug)

Create a new screen object, and initialise the display.

=cut

sub new {
    my ($class, $debug) = @_;
    my $self = fields::new($class);

    binmode(STDOUT, ':utf8');
    ReadMode('cbreak');
    $self->{termcap} = Term::Cap->Tgetent();
    $self->{termcap}->Trequire(qw( cl cm ));
    # Don't enable full-screen mode if we're debugging as it zaps error messages
    $self->{termcap}->Tputs('ti', 1, *STDOUT) if (!$debug);
    $self->{debug} = $debug ? 1 : 0;

    return $self;
}

=item DESTROY()

Restore the display to its original settings.

=cut

sub DESTROY {
    my ($self) = @_;

    $self->{termcap}->Tputs('te', 1, *STDOUT) if (!$self->{debug});
    ReadMode('restore');
}

=back

=head2 Instance Methods

=over

=cut

=item get_size()

Returns the screen width and hieght, in characters.

=cut

sub get_size {
    my ($self) = @_;
    my ($wchar, $hchar, $wpixels, $hpixels) = GetTerminalSize(*STDOUT);

    return($wchar, $hchar);
}

=item clear_screen()

Clears the screen and moves the cursor to the top left.

=cut

sub clear_screen {
    my ($self) = @_;

    $self->{termcap}->Tputs('cl', 1, *STDOUT);
}

=item move_to($x, $y)

Move the cursor to the specified coordinates, where (0, 0) is the top left.

=cut

sub move_to {
    my ($self, $x, $y) = @_;

    $self->{termcap}->Tgoto('cm', $x, $y, *STDOUT);
}

=item read_key()

Block until a key is pressed, then return the key. May be a single character,
or one of the special values from %KEYMAP.

=cut

sub read_key() {
    my ($self) = @_;
    my $key = ReadKey(0, *STDIN);
    my $len = length($key);

    if ($len == 1) {
        my $mapped = $KEYMAP{ord($key)};

        return defined($mapped) ? $mapped : $key;
    } else {
        return '';
    }
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
