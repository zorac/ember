package Ember::Chapter;

=head1 NAME

Ember::Chapter - A chapter of a book.

=head1 DESCRIPTION

This class represents a chapter within a book.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( id path mime skip book prev next );

use Carp;

=head2 Fields

=over

=item id

A unique ID for this chapter.

=item path

The VFS path to this chapter's data.

=item mime

The MIME type of this chapter.

=item skip

If true, this is a skippable chapter.

=item book

A weak link to the containing book.

=item prev

A weak link to the previous chapter.

=item next

A weak link to the next chapter.

=back

=head2 Class Methods

=over

=item new()

Create a new chapter.

=cut

sub new {
    my ($class) = @_;
    my $self = fields::new($class);

    return $self;
}

=back

=head2 Instance Methods

=over

=item lines($width)

Must be implemented by sub-classes to fetch or generate the text lines for this
chapter, restricted to a given display width in characters.

=cut

sub lines {
    croak('Sub-class has not implemented lines()');
}

=back

=head1 SEE ALSO

L<Ember::Book>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
