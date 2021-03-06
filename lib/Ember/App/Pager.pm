package Ember::App::Pager;

=head1 NAME

Ember::App::Pager - An app for paging through content.

=head1 DESCRIPTION

Abstract superclass for Ember apps which display paged text.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::App );
use fields qw( pos lines line_pos line_count page page_size page_count);

=head2 Fields

=over

=item pos

The current reading position within the content.

=item lines

The formatted text lines of the content.

=item line_pos

The reading position corresponding to each line of the content.

=item line_count

The number of lines in the content.

=item page

The current page number within the content.

=item page_size

The current page size (number of visible lines).

=item page_count

The number of pages in the content.

=back

=head2 Class Methods

=over

=item new($args)

Create a pager instance. Should be called on a subclass to get a usable app.
Settable fields: pos (optional).

=cut

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);

    $self->{pos}        = $args->{pos} || 0;
    $self->{lines}      = [];
    $self->{line_count} = 0;
    $self->{line_pos}   = [];
    $self->{page}       = 1;
    $self->{page_size}  = 0;
    $self->{page_count} = 1;

    return $self;
}

=back

=head2 Instance Methods

=over

=item layout($width_changed, $height_changed)

Layout the content for the current screen size. Subclasses should normally
regenerate the fields 'lines', 'line_count', and 'line_pos' (generally only if
the width has changed), and then call: $self->SUPER::layout();

=cut

sub layout {
    my ($self) = @_;
    my $size = $self->{height} - 1;
    my $line_count = $self->{line_count};
    my $page_count = ($line_count == 0) ? 1
        : int(($line_count + $size - 1) / $size);

    $self->{page_size} = $size;
    $self->{page_count} = $page_count;

    if ($self->{pos} < 0) {
        $self->{pos} = 0;
        $self->{page} = $page_count;
        return;
    }

    for (my $page = 1; $page < $page_count; $page++) {
        if ($self->{pos} < $self->{line_pos}[$page * $size]) {
            $self->{page} = $page;
            return;
        }
    }

    $self->{page} = $page_count;
}

=item render()

Render the page at the current reading position.

=cut

sub render {
    my ($self) = @_;
    my $size = $self->{page_size};
    my $last = $self->{page} * $size;
    my $first = $last - $size;
    my $end = $last;

    $last = $self->{line_count} if ($last > $self->{line_count});

    $self->{pos} = $self->{line_pos}[$first];
    $self->{screen}->clear_screen();

    for (my $line = $first; $line < $last; $line++) {
        print $self->{lines}[$line], "\n";
    }

    $self->footer();
}

=item keypress($key)

Handle keypresses for moving forward and backward through pages.

=cut

sub keypress {
    my ($self, $key) = @_;

    if (($key eq ' ') || ($key eq 'n')) {
        $self->page_next();
    } elsif (($key eq 'b') || ($key eq 'p')) {
        $self->page_prev();
    } else {
        return $self->SUPER::keypress($key);
    }
}

=item help_keys()

Return help on the supported keypresses for the application.

=cut

sub help_keys {
    my ($self) = @_;
    my $keys = $self->SUPER::help_keys();

    unshift(@{$keys},
        [ 'Space, N' => 'Go to the next page' ],
        [ 'P, B' => 'Go back to the previous page' ],
    );

    return $keys;
}

=item set_line_data($data)

Shortcut to set the line data for this pager. Input format is the same as the
ouput format for the data() method in L<Ember::Format>.

=cut

sub set_line_data {
    my ($self, $data) = @_;

    $self->{lines} = $data->{lines};
    $self->{line_count} = $data->{line_count};
    $self->{line_pos} = $data->{line_pos};
}

=item footer([ $text [, $persist ] ])

Provides a default footer text displaying the current page.

=cut

sub footer() {
    my ($self, $text, $persist) = @_;

    $self->SUPER::footer($text, $persist,
        '-- Page ' . $self->{page} . '/' . $self->{page_count});
}

=item page_prev()

Go to the previous page.

=cut

sub page_prev() {
    my ($self) = @_;

    if ($self->{page} > 1) {
        $self->{page}--;
        $self->render();
    }
}

=item page_next()

Go to the next page.

=cut

sub page_next() {
    my ($self) = @_;

    if ($self->{page} < $self->{page_count}) {
        $self->{page}++;
        $self->render();
    }
}

=back

=head1 SEE ALSO

L<Ember::App>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
