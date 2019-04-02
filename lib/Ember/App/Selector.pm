package Ember::App::Selector;

=head1 NAME

Ember::App::Selector - An app for selecting an item from a list

=head1 DESCRIPTION

Abstract superclass for Ember apps which allow selecting an item from a list.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::App::Pager );
use fields qw( table input );

use Ember::Format::KeyValue;

=head2 Fields

=over

=item table

The table of contents to display.

=item input

The current input.

=back

=head2 Class Methods

=over

=item new($args)

Create a new table of contents viewer. Settable fields: items (required).

=cut

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    my @table;
    my $i = 1;

    foreach my $item (@{$args->{items}}) {
        push(@table, [ $i++ => $item ]);
    }

    $self->{table} = \@table;

    return $self;
}

=back

=head2 Instance Methods

=over

=item layout($width_changed, $height_changed)

Lay out the selection table for the current screen size.

=cut

sub layout {
    my ($self, $width_changed) = @_;

    if ($width_changed) {
        my $format = Ember::Format::KeyValue->new($self->{width});

        $self->set_line_data($format->data($self->{table}))
    }

    $self->SUPER::layout();
}

=item keypress($key)

Handle keypresses to perform item selection.

=cut

sub keypress {
    my ($self, $key) = @_;
    my $input = $self->{input};

    if ($key =~ /^\d$/) {
        $input = defined($input) ? "$input$key" : $key;
        $self->{input} = $input;
        $self->footer("Go to: $input", 1);
    } elsif ($key eq 'bs') {
        if (defined($input)) {
            my $len = length($input);

            if ($len <= 1) {
                $self->{input} = undef;
                $self->footer(undef, 0);
            } else{
                $input = substr($input, 0, $len - 1);
                $self->{input} = $input;
                $self->footer("Go to: $input", 1);
            }
        }
    } elsif (($key eq 'esc') && defined($input)) {
        $self->{input} = undef;
        $self->footer(undef, 0);
    } elsif (($key eq "\n") && defined($input)) {
        $self->{input} = undef;
        $self->footer(undef, 0);

        if (($input > 0) && ($input <= @{$self->{table}})) {
            return $self->selected($input - 1);
        } else {
            $self->footer("Unknown item: $input", 0);
        }
    } else {
        return $self->SUPER::keypress($key);
    }
}

=item help_keys()

Return help on the supported keypresses for the application.

=cut

sub help_keys {
    my ($self) = @_;
    my $keys = $self->SUPER::help_keys();

    unshift(@{$keys},
        [ '1-9...'      => 'Enter an item number' ],
        [ 'Backspace'   => 'Delete a number' ],
        [ 'Escape'      => 'Cancel item selection' ],
        [ 'Enter'       => 'Select the entered item' ],
    );

    return $keys;
}

=item selected($index)

Called when the user selects the item with the given index. Should return a
command to be passed up the stack.

=cut

sub selected {
    my ($self, $index) = @_;

    # Nothing happens here
}

=back

=head1 SEE ALSO

L<Ember::App::Pager>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
