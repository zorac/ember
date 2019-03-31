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
use base qw( Ember::App::Selector );
use fields qw( ids );

=head2 Fields

=over

=item ids

The chapter IDs.

=back

=head2 Class Methods

=over

=item new($args)

Create a new table of contents viewer. Settable fields: book (required).

=cut

sub new {
    my ($class, $args) = @_;
    my $toc = $args->{book}{toc};
    my (@ids, @titles);

    foreach my $entry ($toc->all_entries()) {
        my $title = $entry->{title};

        $title = (('..' x int($entry->{depth})) . $title) if ($entry->{depth});

        push(@ids, [ $entry->{chapter}, $entry->{anchor} ]);
        push(@titles, $title);
    }

    $args->{items} = \@titles;

    my $self = $class->SUPER::new($args);

    $self->{ids} = \@ids;

    return $self;
}

=back

=head2 Instance Methods

=over

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

=item selected($index)

Called when the user selects a chapter.

=cut

sub selected {
    my ($self, $index) = @_;

    return 'pop', 'chapter', @{$self->{ids}[$index]};
}

=back

=head1 SEE ALSO

L<Ember::App::Selector>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
