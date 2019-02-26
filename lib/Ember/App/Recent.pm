package Ember::App::Recent;

=head1 NAME

Ember::App::Recent - An app for displaying help for another app.

=head1 SYNOPSIS

use Ember::App::Recent;

my $app = Ember::App::Recent->new({ screen => $screen, recent => $recent });

=head1 DESCRIPTION

This class impements a metadata viewer for an eBook.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::App::Selector );
use fields qw( ids );

use Ember::Format::KeyValue;
use Ember::Format::Text;

=head2 Fields

=over

=item ids

The book IDs.

=back

=head2 Class Methods

=over

=item new($args)

Create a new recent books viewer.

=cut

sub new {
    my ($class, $args) = @_;
    my (@ids, @books);
    my $config = $args->{config};
    my $metadata = $config->get_metadata();

    foreach my $recent (@{$config->get_recent()}) {
        my $id = $recent->[1];
        my $meta = $metadata->[$id];
        my $title = $meta->{title} || 'Unknown';
        my $author = $meta->{author} || 'Unknown';

        push(@ids, $id);
        push(@books, "$title by $author");
    }

    $args->{items} = \@books;

    my $self = $class->SUPER::new($args);

    $self->{ids} = \@ids;

    return $self;
}

=back

=head2 Instance Methods

=over

=item help_text()

Provides brief details of the recent books screen.

=cut

sub help_text {
    my ($self) = @_;

    return <<'EOF';
This screen displays your most recently read books.
Type a book number and press enter to open that book.
EOF
}

=item selected($index)

Called when the user selects a book.

=cut

sub selected {
    my ($self, $index) = @_;
    my $id = $self->{ids}[$index];
    my $filename = $self->{config}->get_filename($id);
    my $book = Ember::Book->open($filename, $self->{config});

    return 'push', 'Reader', { book => $book };
}

=back

=head1 SEE ALSO

L<Ember::App>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;