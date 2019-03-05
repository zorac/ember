package Ember::Format;

=head1 NAME

Ember::Format - Text conversion and formatting.

=head1 DESCRIPTION

Abstract superclass for objects which convert raw eBook data into formatted
text for CLI display.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( width );

use Carp;

=head2 Fields

=over

=item width

The width text should be formatted to fit in.

=back

=head2 Class Methods

=over

=item new($width)

Create a new format for a given screen width in characters. You should call
this directly on a subclass if you want an object which is actually useful.

=cut

sub new {
    my ($class, $width) = @_;
    my $self = fields::new($class);

    $self->{width} = $width;

    return $self;
}

=back

=head2 Instance Methods

=over

=item data($input)

Returns data including the lines of text making up the input at this format's
width. Returns a hasref with keys:

=over

=item lines

The lines of text

=item line_count

The number of lines

=item line_pos

The reading position at the start of each line

=item max_pos

The reading position at the end of the last line

=item anchors

A hash of anchors to line numbers

=back

At least one of this and lines(...) must be implemented by subclasses.

=cut

sub data {
    my ($self, $input) = @_;
    my @lines = $self->lines($input);
    my @line_pos;
    my $pos = 0;

    foreach my $line (@lines) {
        push(@line_pos, $pos);
        $pos += split(' ', $line);
    }

    return {
        lines => \@lines,
        line_count => scalar(@lines),
        line_pos => \@line_pos,
        max_pos => $pos,
        anchors => {}
    }
}

=item lines($input)

Returns the lines of text making up the input at this format's width. At least
one of this and data(...) must be implemented by subclasses.

=cut

sub lines {
    my ($self, $input) = @_;

    return @{$self->data($input)->{lines}};
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
