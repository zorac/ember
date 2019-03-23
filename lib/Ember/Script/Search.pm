package Ember::Script::Search;

=head1 NAME

Ember::Script::Search - Search known books for given terms.

=head1 SYNOPSIS

use Ember::Script::Search;

my $ember = Ember::Script::Search->new(@ARGV);

$ember->run();

=head1 DESCRIPTION

Ember script to search book metadata for given terms.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Script );
use fields qw( terms );

use Ember;

=head2 Fields

=over

=item terms

The search terms.

=back

=head2 Class Methods

=over

=item new($args)

Create a new script object by passing an L<Ember::Args> object.

=cut

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    my $terms = $args->{search};

    $self->{terms} = [ split(/[^A-Za-z]+/, $terms) ];

    return $self;
}

=back

=head2 Instance Methods

=over

=item run()

Display the version

=cut

sub run {
    my ($self) = @_;
    my $config = $self->{config};
    my @terms = @{$self->{terms}};
    my @ids = $config->search(@terms);

    foreach my $id (@ids) {
        my ($title, $authors) = $config->get_metadata($id, 'title', 'authors');

        print(($title || 'Unkown'), ' by ',
            (@{$authors} ? join(' & ', @{$authors}) : 'Unknown'), "\n");
    }
}

=back

=head1 SEE ALSO

L<ember>, L<Ember>, L<Ember::Script>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
