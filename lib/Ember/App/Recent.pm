package Ember::App::Recent;

=head1 NAME

Ember::App::Recent - An app for selecting a recently-viewed book.

=head1 SYNOPSIS

use Ember::App::Recent;

my $app = Ember::App::Recent->new({ screen => $screen, recent => $recent });

=head1 DESCRIPTION

This class displays a list of recently-viewed books anad allows the user to
select one to read.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::App::Selector );
use fields qw( ids );

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
    my $config = $args->{config};
    my @ids = $config->get_recent();
    my @books;

    foreach my $id (@ids) {
        my ($title, $authors) = $config->get_metadata($id, 'title', 'authors');

        push(@books, ($title || 'Unkown') . ' by '
            . (@{$authors} ? join(' & ', @{$authors}) : 'Unknown'));
    }

    $args->{items} = \@books;

    my $self = $class->SUPER::new($args);

    $self->{ids} = \@ids;

    return $self;
}

=back

=head2 Instance Methods

=over

=item keypress($key)

Handle a keypress for switching to search mode.

=cut

sub keypress {
    my ($self, $key) = @_;

    if ($key eq 's') {
        return 'push', 'SearchFilter';
    } else {
        return $self->SUPER::keypress($key);
    }
}

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

=item help_keys()

Return help on the supported keypresses for the application.

=cut

sub help_keys {
    my ($self) = @_;
    my $keys = $self->SUPER::help_keys();

    push(@{$keys},
        [ S => 'Search for books' ],
    );

    return $keys;
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

L<Ember::App::Selector>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
