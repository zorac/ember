package Ember::EPub::Chapter;

=head1 NAME

Ember::EPub::Chapter - A chapter of an EPUB book.

=head1 DESCRIPTION

This class represents a chapter within an EPUB book.

=cut

use strict;
use warnings;
use base qw( Ember::Chapter );

=head2 Instance Methods

=over

=item lines($width)

Find the HTML file for this chapter, render it into text of the given width,
and return an array of line.

=cut

sub lines {
    my ($self, $width) = @_;
    my $book = $self->{book};
    my $path = $book->{rootpath} . $self->{path};
    my $content = $book->{vfs}->content($path);

    return $book->{formatter}->format($content, $width);
}

=back

=head1 SEE ALSO

L<Ember::Chapter>, L<Ember::EPub::Book>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;