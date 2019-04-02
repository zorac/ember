package Ember::App::SearchSelect;

=head1 NAME

Ember::App::SearchSelect - An app for selecting a search result.

=head1 SYNOPSIS

use Ember::App::SearchSelect;

my $app = Ember::App::SearchSelect->new({ screen => $screen });

=head1 DESCRIPTION

This class allows the user to select a search result to read.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::App::Selector );
use fields qw( ids metadata );

=head2 Fields

=over

=item ids

The IDs of the search results.

=item metadata

Cached metadata for the search results.

=back

=head2 Class Methods

=over

=item new($args)

Create a new search results app.

=cut

sub new {
    my ($class, $args) = @_;
    my $config = $args->{config};
    my $metadata = $args->{metadata};
    my @items = map { $_->[0] . ' by ' . $_->[1] } @{$metadata};

    $args->{items} = \@items;

    my $self = $class->SUPER::new($args);

    $self->{ids}        = $args->{ids};
    $self->{metadata}   = $metadata;

    return $self;
}

=back

=head2 Instance Methods

=over

=item help_text()

Provides brief details of the search results screen.

=cut

sub help_text {
    my ($self) = @_;

    return <<'EOF';
This screen displays search results.
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

L<Ember::App::Selector>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
