package Ember::Screen;

=head1 NAME

Ember::Screen - Console screen management for Ember.

=head1 SYNOPSIS

use Ember::Screen;

my $screen = Ember::Screen->new();

=head1 DESCRIPTION

Extends Term::ANSIScreen to provide additional functionality.

=cut

use 5.008;
use strict;
use warnings;
use fields;

use Term::ANSIScreen qw( locate cls );
use Term::ReadKey;

our %KEYMAP = (
    27  => 'esc',
    127 => 'bs',
);

=head2 Class Methods

=over

=item new()

Create a new screen object, and configure the display.

=cut

sub new {
    my ($class) = @_;
    my $self = fields::new($class);

    binmode(STDOUT, ':utf8');
    ReadMode(3); # noecho

    return $self;
}

=item DESTROY()

Restore the display to its original settings.

=cut

sub DESTROY {
    ReadMode(0); # restore
}

=back

=head2 Instance Methods

=over

=cut

=item get_size()

Returns the screen width and hieght, in characters.

=cut

sub get_size {
    my ($wchar, $hchar, $wpixels, $hpixels) = GetTerminalSize();

    return($wchar, $hchar);
}

=item clear_screen()

Clears the screen.

=cut

sub clear_screen {
    print STDERR cls();
}

=item move_to($x, $y)

Move the cursor to the specified coordinates, where (1, 1) is the top left.

=cut

sub move_to {
    my ($self, $x, $y) = @_;

    print STDERR locate($y, $x);
}

=item read_key()

Block until a key is pressed, then return the key. May be a single character,
or one of the special values from %KEYMAP.

=cut

sub read_key() {
    my $key = ReadKey(0);
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
