package Ember::App::Pager;

=head1 NAME

Ember::Pager - An app for paging through content.

=head1 SYNOPSIS

use Ember::Pager;

=head1 DESCRIPTION

This class impements a generic pager application.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::App );
use fields qw( pos lines lines_pos line_count page page_size page_count );

=head2 Fields

=over

=item pos

The current reading position within the content.

=item lines

The formatted text lines of the content.

=item lines_pos

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

    $self->{pos} = $args->{pos} || 0;
    $self->{lines} = [];
    $self->{lines_pos} = [];
    $self->{line_count} = 0;
    $self->{page} = 1;
    $self->{page_size} = 0;
    $self->{page_count} = 1;

    return $self;
}

=back

=head2 Instance Methods

=over

=item layout()

Layout the content for the current screen size.

=cut

sub layout {
    my ($self) = @_;
    my $size = $self->{height} - 1;
    my @lines = @{$self->{lines}};
    my $page_count = (@lines == 0) ? 1 : int((@lines + $size - 1) / $size);
    my @lines_pos;
    my $pos = 0;

    foreach my $line (@lines) {
        push(@lines_pos, $pos);
        $pos += split(' ', $line);
    }

    $self->{lines_pos} = \@lines_pos;
    $self->{line_count} = @lines;
    $self->{page_size} = $size;
    $self->{page_count} = $page_count;

    if ($self->{pos} < 0) {
        $self->{pos} = 0;
        $self->{page} = $page_count;
        return;
    }

    for (my $page = 1; $page < $page_count; $page++) {
        if ($self->{pos} < $lines_pos[$page * $size]) {
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
    my $line = $first;

    $last = $self->{line_count} if ($last > $self->{line_count});

    $self->{pos} = $self->{lines_pos}[$first];
    $self->{screen}->Cls();
    $self->{screen}->Cursor(0, 0);

    for (; $line < $last; $line++) {
        print $self->{lines}[$line], "\n";
    }

    for (; $line < $end; $line++) {
        print "\n";
    }

    print '-- Page ' . $self->{page} . '/' . $self->{page_count};
    STDOUT->flush();

    # TODO footer row
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
