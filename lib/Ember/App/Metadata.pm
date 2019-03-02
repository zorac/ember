package Ember::App::Metadata;

=head1 NAME

Ember::App::Metadata - An app for displaying book metadata.

=head1 SYNOPSIS

use Ember::App::Metadata;

my $app = Ember::App::Metadata->new({ screen => $screen, book => $book });

=head1 DESCRIPTION

This class impements a metadata viewer for an eBook.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::App::Pager );
use fields qw( table table_formatter text text_formatter );

use Ember::Format::KeyValue;
use Ember::Format::Text;

=head2 Fields

=over

=item table

The metadata table to display.

=item table_formatter

The table formatter to use.

=item text

The metadata text to display.

=item text_formatter

The text formatter to use.

=back

=head2 Class Methods

=over

=item new($args)

Create a new metadata viewer. Settable fields: book (required).

=cut

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    my @meta = $args->{book}->display_metadata();

    if (@meta) {
        if (!defined($meta[$#meta][0])) {
            my $text = pop(@meta);

            $self->{text} = $text->[1];
            $self->{text_formatter} = Ember::Format::Text->new();
        }

        if (@meta) {
            $self->{table} = \@meta;
            $self->{table_formatter} = Ember::Format::KeyValue->new();
        }
    }

    return $self;
}

=back

=head2 Instance Methods

=over

=item layout($width_changed, $height_changed)

Layout the metadata for the current screen size.

=cut

sub layout {
    my ($self, $width_changed) = @_;

    if ($width_changed) {
        my $width = $self->{width};
        my $table = $self->{table};
        my $text = $self->{text};
        my @lines;

        push(@lines, $self->{table_formatter}->format($width, $table))
            if ($table);
        push(@lines, '') if ($table && $text);
        push(@lines, $self->{text_formatter}->format($width, $text))
            if ($text);

        $self->{lines} = \@lines;
    }

    $self->SUPER::layout();
}

=item help_text()

Provides brief details of the metadata screen.

=cut

sub help_text {
    my ($self) = @_;

    return <<'EOF';
This screen displays information about the currently selected book.
EOF
}

=back

=head1 SEE ALSO

L<Ember::App::Pager>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
