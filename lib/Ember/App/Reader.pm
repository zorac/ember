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
use fields qw( book chapter );

use Ember::App::Metadata;

=head2 Fields

=over

=item book

The book being read.

=item chapter

The chapter currently being read.

=back

=head2 Class Methods

=over

=item new($args)

Create a reader instance. Settable fields: book (required), chapter (optional,
passed as name/id).

=cut

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);

    $self->{book} = $args->{book};
    $self->{chapter} = $self->{book}->chapter($args->{chapter});

    return $self;
}

=back

=head2 Instance Methods

=over

=item layout($width_changed, $height_changed)

Layout the current chapter for the current screen size.

=cut

sub layout {
    my ($self, $width_changed) = @_;

    if ($width_changed) {
        my @lines = $self->{chapter}->lines($self->{width});

        $self->{lines} = \@lines;
    }

    $self->SUPER::layout();
}

=item keypress($key)

Handle a keypress for displaying book information.

=cut

sub keypress {
    my ($self, $key) = @_;

    if ($key eq 'i') {
        return 'push', Ember::App::Metadata->new({
            screen => $self->{screen},
            book => $self->{book},
        });
    } else {
        return $self->SUPER::keypress($key);
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
            $self->layout();
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
            $self->layout();
            $self->render();
        }
    } else {
        $self->SUPER::page_next();
    }
}

=back

=head1 SEE ALSO

L<Emeber>, L<Ember::App::Pager>, L<Ember::Book>, L<Ember::Chapter>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
