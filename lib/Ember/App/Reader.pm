package Ember::App::Reader;

=head1 NAME

Ember::Reader - An eBook reader implementation.

=head1 SYNOPSIS

use Ember::App::Reader;

my $reader = Ember::App::Reader->new({ screen => $screen, book => $book });

=head1 DESCRIPTION

This class impements a reader app for an eBook.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::App::Pager );
use fields qw( book chapter anchor );

=head2 Fields

=over

=item book

The book being read.

=item chapter

The chapter currently being read.

=item anchor

An anchor to be jumped to.

=back

=head2 Class Methods

=over

=item new($args)

Create a reader instance. Settable fields: book (required)

=cut

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    my $book = $args->{book};
    my ($chapter, $pos, $anchor) = $book->get_pos();

    $self->{book}       = $book;
    $self->{chapter}    = $chapter;
    $self->{pos}        = $pos;
    $self->{anchor}     = $anchor;

    return $self;
}

=back

=head2 Instance Methods

=over

=item layout($width_changed, $height_changed)

Layout the current chapter for the current screen size.

=cut

sub layout {
    my ($self, $changed) = @_;

    if ($changed) {
        my $data = $self->{chapter}->data($self->{width});

        if ($self->{anchor}) {
            $self->{pos} = $data->{anchors}{$self->{anchor}} || 0;
            delete($self->{anchor});
        }

        $self->set_line_data($data);
    }

    $self->SUPER::layout();
}

=item keypress($key)

Handle a keypress for displaying book information.

=cut

sub keypress {
    my ($self, $key) = @_;

    if ($key eq 'c') {
        return 'push', 'Contents', { book => $self->{book} };
    } elsif ($key eq 'i') {
        return 'push', 'Metadata', { book => $self->{book} };
    } else {
        return $self->SUPER::keypress($key);
    }
}

=item help_text()

Provides brief details of the reader screen.

=cut

sub help_text {
    my ($self) = @_;

    return <<'EOF';
This screen displays the contents of the currently selected book. You can go to
the next page by hitting the spacebar, and go back by pressing 'B'. Press 'I'
to view information about the book, and 'C' to view the table of contents,
which also allows you to jump directly to any chapter.
EOF
}

=item help_keys()

Return help on the supported keypresses for the application.

=cut

sub help_keys {
    my ($self) = @_;
    my $keys = $self->SUPER::help_keys();

    push(@{$keys},
        [ I => 'Display information about this book' ],
        [ C => 'View the table of contents' ],
    );

    return $keys;
}

=item command($command, @args)

Receive a command from another app.

=cut

sub command {
    my ($self, $command, @args) = @_;

    if ($command eq 'chapter') {
        my ($id, $anchor) = @args;
        my $chapter = $self->{book}->chapter($id);

        if (defined($chapter)) {
            $self->{chapter} = $chapter;
            $self->{pos} = 0;
            $self->{anchor} = $anchor;
            $self->layout(1); # TODO mark as dirty instead?
        }
    }
}

=item page_prev()

Go to the previous page, moving to the previous chapter if neede.

=cut

sub page_prev() {
    my ($self) = @_;

    if ($self->{page} <= 1) {
        my $chapter = $self->{chapter}{prev};

        if ($chapter) {
            $self->{chapter} = $chapter;
            $self->{pos} = -1;
            $self->layout(1);
            $self->render();
        }
    } else {
        $self->SUPER::page_prev();
    }
}

=item page_next()

Go to the next page, moving to the next chapter if needed.

=cut

sub page_next() {
    my ($self) = @_;

    if ($self->{page} >= $self->{page_count}) {
        my $chapter = $self->{chapter}{next};

        if ($chapter) {
            $self->{chapter} = $chapter;
            $self->{pos} = 0;
            $self->layout(1);
            $self->render();
        }
    } else {
        $self->SUPER::page_next();
    }
}

=item close()

Save the current reading position.

=cut

sub close {
    my ($self) = @_;

    $self->{book}->save_pos($self->{chapter}, $self->{pos});
}

=back

=head1 SEE ALSO

L<Emeber>, L<Ember::App::Pager>, L<Ember::Book>, L<Ember::Chapter>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
