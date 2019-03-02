package Ember::Chapter;

=head1 NAME

Ember::Chapter - A chapter of a book.

=head1 DESCRIPTION

This is an abstract superclass for objects which represent a chapter within a
book.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( id title path mime skip book prev next );

use Carp;
use Scalar::Util qw( weaken );

=head2 Fields

=over

=item id

A unique ID for this chapter.

=item title

This chapter's title.

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

=item new($args)

Create a new chapter. All fields are settable, and should not be set otherwise.
Setting prev/next will automatically set the reverse relationship.

=cut

sub new {
    my ($class, $args) = @_;
    my $self = fields::new($class);
    my $book = $args->{book};
    my $prev = $args->{prev};
    my $next = $args->{next};

    $self->{id} = $args->{id};
    $self->{title} = $args->{title};
    $self->{path} = $args->{path};
    $self->{mime} = $args->{mime};
    $self->{skip} = $args->{skip} ? 1 : 0;
    weaken($self->{book} = $book) if ($book);

    if ($prev) {
        weaken($self->{prev} = $prev);
        weaken($prev->{next} = $self);
    }

    if ($next) {
        weaken($self->{next} = $next);
        weaken($next->{prev} = $self);
    }

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
    my ($self, $width) = @_;

    croak(ref($self) . ' has not implemented lines()');
}

=back

=head1 SEE ALSO

L<Ember::Book>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
