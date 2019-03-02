package Ember::Script::Dump;

=head1 NAME

Ember - A CLI-based reader for eBooks.

=head1 SYNOPSIS

use Ember::Script::Dump;

my $ember = Ember::Script::Dump->new(@ARGV);

$ember->run();

=head1 DESCRIPTION

Ember script to dump an ebook.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( book );

use Ember::Book;
use Ember::Config;

=head2 Fields

=over

=item book

The book to be dumped.

=back

=head2 Class Methods

=over

=item new($args)

Create a new script object by passing an L<Ember::Args> object.

=cut

sub new {
    my ($class, $args) = @_;
    my $self = fields::new($class);

    $self->{book} = Ember::Book->open($args->{dump}, Ember::Config->open());

    return $self;
}

=back

=head2 Instance Methods

=over

=item run()

Run the reader application.

=cut

sub run {
    my ($self) = @_;
    my $book = $self->{book};
    my $first = 1;

    binmode(STDOUT, ':utf8');

    foreach my $chapter (@{$book->{chapters}}) {
        next if ($chapter->{skip});

        if ($first) {
            $first = 0;
        } else {
            print $/, $/, ' ' x 30, '~' x 20, $/, $/, $/;
        }

        foreach my $line ($chapter->lines(80)) { # TODO make that configurable
            print $line, $/;
        }
    }
}

=back

=head1 SEE ALSO

L<ember>, L<Ember::Args>, L<Ember::Book>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
