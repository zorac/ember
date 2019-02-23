package Ember::App::Contents;

=head1 NAME

Ember::App::Contents - An app for displaying a book's table of contents.

=head1 SYNOPSIS

use Ember::App::Contents;

my $app = Ember::App::Contents->new({ screen => $screen, book => $book });

=head1 DESCRIPTION

This class impements a table-of-contens viewer for an eBook.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::App::Pager );
use fields qw( ids table formatter input );

use Ember::Format::KeyValue;

=head2 Fields

=over

=item table

The table of contents to display.

=item formatter

The table formatter to use.

=back

=head2 Class Methods

=over

=item new($args)

Create a new table of contents viewer. Settable fields: book (required).

=cut

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    my (@ids, @table);
    my $i = 1;

    foreach my $chapter (@{$args->{book}{chapters}}) {
        next if ($chapter->{skip});
        $ids[$i] = $chapter->{id};
        push(@table, [ $i => $chapter->{title} ]);
        $i++;
    }

    $self->{ids} = \@ids;
    $self->{table} = \@table;
    $self->{formatter} = Ember::Format::KeyValue->new();

    return $self;
}

=back

=head2 Instance Methods

=over

=item layout($width_changed, $height_changed)

Lay out the table of contents for the current screen size.

=cut

sub layout {
    my ($self, $width_changed) = @_;

    if ($width_changed) {
        my @lines = $self->{formatter}->format($self->{width}, $self->{table});

        $self->{lines} = \@lines;
    }

    $self->SUPER::layout();
}

=item keypress($key)

Handle keypresses to perform chapter selection.

=cut

sub keypress {
    my ($self, $key) = @_;
    my $input = $self->{input};

    if ($key =~ /^\d$/) {
        $input = defined($input) ? "$input$key" : $key;
        $self->{input} = $input;
        $self->footer("Go to: $input", 1);
    } elsif ($key eq 'bs') {
        if (defined($input)) {
            my $len = length($input);

            if ($len <= 1) {
                $self->{input} = undef;
                $self->footer(undef, 0);
            } else{
                $input = substr($input, 0, $len - 1);
                $self->{input} = $input;
                $self->footer("Go to: $input", 1);
            }
        }
    } elsif (($key eq 'esc') && defined($input)) {
        $self->{input} = undef;
        $self->footer(undef, 0);
    } elsif (($key eq "\n") && defined($input)) {
        my $id = $self->{ids}[$input];

        if (defined($id)) {
            return 'pop', 'chapter', $id;
        } else {
            $self->{input} = undef;
            $self->footer("Unknown chapter number: $input", 0);
        }
    } else {
        return $self->SUPER::keypress($key);
    }
}

=item help_text()

Provides brief details of the table of contents.

=cut

sub help_text {
    my ($self) = @_;

    return <<'EOF';
This screen displays the table of contents the currently selected book.
Type a chapter number and press enter to jump directly to that chapter.
EOF
}

=item help_keys()

Return help on the supported keypresses for the application.

=cut

sub help_keys {
    my ($self) = @_;
    my $keys = $self->SUPER::help_keys();

    push(@{$keys},
        [ '1-9...' => 'Type a chapter number' ],
    );

    return $keys;
}

=back

=head1 SEE ALSO

L<Ember::App>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
