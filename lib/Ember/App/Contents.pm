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
use fields qw( table formatter );

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
    my @table;
    my $i = 1;

    foreach my $chapter (@{$args->{book}{chapters}}) {
        push(@table, [ $i++ => $chapter->{title} ]);
    }

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

=back

=head1 SEE ALSO

L<Ember::App>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
