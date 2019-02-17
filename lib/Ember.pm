package Ember;

=head1 NAME

Ember - A CLI-based reader for eBooks.

=head1 SYNOPSIS

use Ember;

my $ember = Ember->new(@ARGV);

$ember->run();

=head1 DESCRIPTION

This class is the entrypoint for the Ember application.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( config screen app stack );

use Carp;
use Cwd qw( realpath );
use Term::ANSIScreen;
use Term::ReadKey;

use Ember::Book;
use Ember::Config;
use Ember::App::Reader;

our $VERSION = '0.04';

=head2 Fields

=over

=item config

A configuration instance.

=item screen

The screen object used to display Ember.

=item app

The currently displayed app.

=item stack

The stack of displayed apps.

=back

=head2 Class Methods

=over

=item new(@ARGV)

Create a new application object by passing command-line arguments. See L<ember>
for details on supported arguments.

=cut

sub new {
    my ($class, @args) = @_;
    my $self = fields::new($class);

    # TODO better arg parsing & usage

    if (@args == 0) {
        print <<"EOF";
Usage: $0 <eBook filename> [<chapter name>]
EOF
        exit(1);
    }

    my $filename = realpath($args[0]);
    my $chapter = $args[1];

    croak('Unable to locate requested file')
        unless ($filename && -e $filename);

    $self->{config} = Ember::Config->open();
    $self->{screen} = Term::ANSIScreen->new();

    my $book = Ember::Book->open($filename);
    my %pos = $chapter ? ( chapter => $chapter )
        : $self->{config}->get_pos($filename);
    my $reader = Ember::App::Reader->new({
        screen => $self->{screen},
        book => $book,
        chapter => $pos{chapter},
        pos => $pos{pos}
    });

    $self->{app} = $reader;
    $self->{stack} = [ $reader ];

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

    binmode(STDOUT, ':utf8');
    ReadMode(3); # noecho
    $self->display();
    $SIG{WINCH} = sub { $self->display() };

    while (1) {
        my $key = ReadKey(0);
        my ($command, @args) = $self->{app}->keypress($key);

        if (!defined($command)) {
            next;
        } elsif ($command eq 'push') {
            my $app = $args[0]; # TODO check?

            push(@{$self->{stack}}, $app);
            $self->{app} = $app;
            $self->display();
        } elsif ($command eq 'pop') {
            my $stack = $self->{stack};
            my $count = @{$stack};

            last if ($count == 1);

            pop(@{$stack});
            $self->{app} = $stack->[$count - 2];
            $self->display();
        } elsif ($command eq 'quit') {
            last;
        } # TODO menu, save pos, etc, etc
    }

    $SIG{WINCH} = undef;
    $self->{config}->save_pos($self->{app}); # TODO make this generic
    ReadMode(0); # restore
    print "\n"
}

=item display()

Display the current app at the current screen size.

=cut

sub display {
    my ($self) = @_;
    my ($wchar, $hchar, $wpixels, $hpixels) = GetTerminalSize();

    $self->{app}->display($wchar, $hchar);
}

=back

=head1 SEE ALSO

L<ember>, L<Ember::Book>, L<Ember::Config>, L<Ember::App::Reader>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
