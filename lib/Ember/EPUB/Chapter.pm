package Ember::EPUB::Chapter;

=head1 NAME

Ember::EPUB::Chapter - A chapter of an EPUB book.

=head1 DESCRIPTION

This class represents a chapter within an EPUB book.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Chapter );

use Ember::Format::HTML;

=head2 Instance Methods

=over

=item data($width)

Find the HTML file for this chapter, render it into text of the given width,
and return the lines and other data. Return value is the same format as the
data(...) method in L<Ember::Format>.

=cut

sub data {
    my ($self, $width) = @_;
    my $book = $self->{book};
    my $path = $book->{rootpath} . $self->{path};
    my $content = $book->{vfs}->read_text($path);
    my $format = Ember::Format::HTML->new($width);

    return $format->data($content);
}

=back

=head1 SEE ALSO

L<Ember::Chapter>, L<Ember::EPUB::Book>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
