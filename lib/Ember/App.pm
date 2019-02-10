package Ember::App;

=head1 NAME

Ember::App - A CLI-based reader for eBooks.

=head1 SYNOPSIS

use Ember::App;

my $app = Ember::App->new(@ARGV);

$app->run();

=head1 DESCRIPTION

This class is the entrypoint for the Ember application.

=cut

use strict;
use warnings;

use Cwd qw( realpath );

use Ember::Book;
use Ember::Config;
use Ember::Reader;

=head2 Class Methods

=over

=item new(@ARGV)

Create a new application object by passing command-line arguments. See L<ember>
for details on supported arguments.

=cut

sub new {
    my ($this, @args) = @_;
    my $class = ref($this) || $this;
    my $self = {};

    # TODO better arg parsing & usage

    if (@args == 0) {
        print <<"EOF";
Usage: $0 <eBook filename> [<chapter name>]
EOF
        exit(1);
    }

    my $filename = realpath($args[0]);

    die('Unable to locate requested file')
        unless ($filename && -e $filename);

    $self->{filename} = $filename;
    $self->{chapter} = $args[1];

    return bless($self, $class);
}

=back

=head2 Instance Methods

=over

=item run()

Run the reader application.

=cut

sub run {
    my ($self) = @_;
    my $config = Ember::Config->open();
    my $book = Ember::Book->open($self->{filename});
    my %pos = $self->{chapter} ? ( chapter => $self->{chapter} )
        : $config->get_pos($self->{filename});

    my $reader = Ember::Reader->new($book, $pos{chapter}, $pos{pos});

    binmode(STDOUT, ':utf8');

    $reader->run;
    $config->save_pos($reader);

    # TODO menu, save pos, etc, etc
}

=back

=head1 SEE ALSO

L<ember>, L<Ember::Book>, L<Ember::Config>, L<Ember::Reader>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
