#!/usr/bin/perl

package Ember::Reader;

use strict;
use warnings;
use fields qw( book chapter pos width height lines lines_pos line_count page page_size page_count screen );

use Term::ANSIScreen;
use Term::ReadKey;

sub new {
    my ($self, $book, $chapter, $pos) = @_;
    my ($wchar, $hchar, $wpixels, $hpixels) = GetTerminalSize();

    $self = fields::new($self) unless (ref($self));
    $self->{book} = $book;
    $self->{chapter} = $book->chapter($chapter);
    $self->{pos} = defined($pos) ? int($pos) : 0;
    $self->{width} = $wchar;
    $self->{height} = $hchar;

    return $self;
}

sub run {
    my ($self) = @_;

    ReadMode(3); # noecho
    $self->{screen} = Term::ANSIScreen->new();

    $self->format();
    $self->display();

    $SIG{WINCH} = sub { $self->resize() };

    while (1) {
        my $key = ReadKey(0);

        if ($key eq ' ') {
            $self->page_next();
        } elsif ($key eq 'b') {
            $self->page_prev();
        } elsif ($key eq 'q') {
            last;
        }
    }

    $SIG{WINCH} = undef;
    ReadMode(0); # restore
    print "\n";
}

sub format {
    my ($self) = @_;
    my $size = $self->{height} - 1;
    my @lines = $self->{chapter}->lines($self->{width});
    my $page_count = int((@lines + $size - 1) / $size);
    my @lines_pos;
    my $pos = 0;

    foreach my $line (@lines) {
        push(@lines_pos, $pos);
        $pos += split(' ', $line);
    }

    $self->{lines} = \@lines;
    $self->{lines_pos} = \@lines_pos;
    $self->{line_count} = @lines;
    $self->{page_size} = $size;
    $self->{page_count} = $page_count;

    if ($self->{pos} < 0) {
        $self->{page} = $page_count - 1;
        return;
    }

    for (my $page = 1; $page < $page_count; $page++) {
        if ($self->{pos} < $lines_pos[$page * $size]) {
            $self->{page} = $page - 1;
            return;
        }
    }

    $self->{page} = $page_count - 1;
}

sub display {
    my ($self) = @_;
    my $size = $self->{page_size};
    my $first = $self->{page} * $size;
    my $last = $first + $size;
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

    print '-- Page ' . ($self->{page} + 1) . '/' . $self->{page_count};

    # TODO footer row
}

sub resize {
    my ($self) = @_;
    my ($wchar, $hchar, $wpixels, $hpixels) = GetTerminalSize();

    if ($wchar != $self->{width}) {
        $self->{width} = $wchar;
        $self->format();
    } elsif ($hchar == $self->{height}) {
        return; # Size not actually changed
    }

    $self->{height} = $hchar;
    $self->display();
}

sub page_prev() {
    my ($self) = @_;

    if ($self->{page} <= 0) {
        my $chapter = $self->{chapter}{prev};

        if ($chapter) {
            $self->{chapter} = $chapter;
            $self->{pos} = -1;
            $self->format();
            $self->display();
        }
    } else {
        $self->{page}--;
        $self->display();
    }
}

sub page_next() {
    my ($self) = @_;

    $self->{page}++;

    if ($self->{page} >= $self->{page_count}) {
        my $chapter = $self->{chapter}{next};

        if ($chapter) {
            $self->{chapter} = $chapter;
            $self->{pos} = 0;
            $self->format();
            $self->display();
        } else {
            $self->{page} = $self->{page_count} - 1;
        }
    } else {
        $self->display();
    }
}

1;
