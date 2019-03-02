package Ember;

=head1 NAME

Ember - A CLI-based reader for eBooks.

=head1 SYNOPSIS

use Ember;

my $ember = Ember->new($args);

$ember->run();

=head1 DESCRIPTION

This class is the entrypoint for the Ember application.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( config screen app stack );

use Carp;

use Ember::Book;
use Ember::Config;
use Ember::Screen;
use Ember::Util;

our $VERSION = '0.08';

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

=item new($args)

Create a new application object by passing an L<Ember::Args> object.

=cut

sub new {
    my ($class, $args) = @_;
    my $self = fields::new($class);

    $self->{config} = Ember::Config->open();
    $self->{screen} = Ember::Screen->new();
    $self->{stack} = [];

    if ($args->{book}) {
        my $book = Ember::Book->open($args->{book}, $self->{config});

        $self->push_app('Reader', { book => $book });
    } else {
        $self->push_app('Recent');
    }

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

    $self->display();
    $SIG{WINCH} = sub { $self->display() };

    while (1) {
        my $key = lc($self->{screen}->read_key());
        my ($command, @args) = $self->{app}->keypress($key);

        if (!defined($command)) {
            next;
        } elsif ($command eq 'push') {
            $self->push_app(@args);
            $self->display();
        } elsif ($command eq 'pop') {
            my $app = $self->pop_app();

            last if (!$app);

            $app->command(@args) if (@args);
            $self->display();
        } elsif ($command eq 'quit') {
            foreach my $app (@{$self->{stack}}) {
                $app->close();
            }

            last;
        } # TODO menu, save pos, etc, etc
    }

    $SIG{WINCH} = undef;
}

=item display()

Display the current app at the current screen size.

=cut

sub display {
    my ($self) = @_;
    my ($width, $height) = $self->{screen}->get_size();

    $self->{app}->display($width, $height);
}

=item push_app($name [, $args])

Push an app onto the stack and return it.

=cut

sub push_app {
    my ($self, $name, $args) = @_;
    my $class = get_class('App', $name);

    $args = {} if (!$args);
    $args->{config} = $self->{config};
    $args->{screen} = $self->{screen};

    my $app = $class->new($args);

    push(@{$self->{stack}}, $app);
    $self->{app} = $app;

    return $app;
}

=item pop_app()

Pop the top app off the stack and return the new top app.

=cut

sub pop_app {
    my ($self) = @_;
    my $stack = $self->{stack};
    my $count = @{$stack};

    return if ($count == 0);

    my $app = pop(@{$stack});

    $app->close();

    if ($count == 1) {
        $self->{app} = undef;
    } else {
        $app = $stack->[$count - 2];
        $self->{app} = $app;

        return $app;
    }
}

=back

=head1 SEE ALSO

L<ember>, L<Ember::Args>, L<Ember::Screen>, L<Ember::App>, L<Ember::Config>,
L<Ember::Book>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
