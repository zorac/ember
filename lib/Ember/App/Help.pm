package Ember::App::Help;

=head1 NAME

Ember::App::Help - An app for displaying help for another app.

=head1 SYNOPSIS

use Ember::App::Help;

my $app = Ember::App::Help->new({ screen => $screen, app => $app });

=head1 DESCRIPTION

This class impements a metadata viewer for an eBook.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::App::Pager );
use fields qw( text keys text_formatter table_formatter );

use Ember::Format::KeyValue;
use Ember::Format::Text;

=head2 Fields

=over

=item text

The help text.

=item keys

The supported keypresses.

=item text_formatter

The text formatter to use.

=item table_formatter

The table formatter to use.

=back

=head2 Class Methods

=over

=item new($args)

Create a new metadata viewer. Settable fields: app (required).

=cut

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    my $text = $args->{app}->help_text();

    if (defined($text) && ($text ne '')) {
        $text .= "\n\n";
    } else {
        $text = '';
    }

    $text .= 'The following keypresses are supported:';

    $self->{text} = $text;
    $self->{keys} = $args->{app}->help_keys();
    $self->{text_formatter} = Ember::Format::Text->new();
    $self->{table_formatter} = Ember::Format::KeyValue->new();

    return $self;
}

=back

=head2 Instance Methods

=over

=item layout($width_changed, $height_changed)

Layout the help text for the parent app.

=cut

sub layout {
    my ($self, $width_changed) = @_;

    if ($width_changed) {
        my $width = $self->{width};
        my @lines = ( $self->{text_formatter}->format($width, $self->{text}),
            '', $self->{table_formatter}->format($width, $self->{keys}) );

        $self->{lines} = \@lines;
    }

    $self->SUPER::layout();
}

=item keypress($key)

Prevent the help key from bubbling up and providing help on help!

=cut

sub keypress {
    my ($self, $key) = @_;

    if ($key eq 'h') {
        # Do nothing - avoid looping!
    } else {
        return $self->SUPER::keypress($key);
    }
}

=back

=head1 SEE ALSO

L<Ember::App>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
