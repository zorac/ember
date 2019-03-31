package Ember::Format::Document;

=head1 NAME

Ember::Format::Document - Abstract superclass for document formats.

=head1 DESCRIPTION

This class provides a common frameworkf for rendering documents to text.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Format );
use fields qw( lines line_pos anchors pos line llen space indent indent_once );

=head2 Fields

=over

=item lines

The formatted lines of text during formatting.

=item line_pos

Reading positions at the start of each line.

=item anchors

Any anchor points detected during rendering.

=item pos

Current reading position.

=item line

The current line of text during formatting.

=item llen

The length of the current line of text during formatting.

=item space

0 or 1 depending on if we have a space to carry forward.

=item indent

A number of spaces to indent each line.

=item indent_once

A number of spaces to indent the first line of the next paragraph..

=back

=head2 Instance Methods

=over

=item data($input)

Renders a document to lines of text.

=cut

sub data {
    my ($self, $input) = @_;
    my (@lines, %anchors);
    my @line_pos = ( 0 );

    $input = '' if (!defined($input));

    # Initialise the format
    $self->{lines} = \@lines;
    $self->{line_pos} = \@line_pos;
    $self->{pos} = 0;
    $self->{anchors} = \%anchors;
    $self->{line} = '';
    $self->{llen} = 0;
    $self->{space} = 0;
    $self->{indent} = 0;
    $self->{indent_once} = 0;

    $self->render($input); # Do the hard work!

    $self->newline(); # Make sure everything's output
    pop(@line_pos); # We always have a spare one on the end

    while (@lines && ($lines[$#lines] eq '')) { # Remove trailing empty lines
        pop(@lines);
        pop(@line_pos);
    }

    # Create our return object
    my $result = {
        lines       => \@lines,
        line_count  => scalar(@lines),
        line_pos    => \@line_pos,
        max_pos     => $self->{pos},
        anchors     => \%anchors,
    };

    # Clean up the format
    undef($self->{lines});
    undef($self->{line_pos});
    undef($self->{pos});
    undef($self->{anchors});
    undef($self->{line});
    undef($self->{llen});
    undef($self->{space});
    undef($self->{indent});
    undef($self->{indent_once});

    # And we're done
    return $result;
}

=item render($input)

Called by data(...) after initialisation to render the document.

=cut

sub render {
    my ($self, $input) = @_;

    croak(ref($self) . ' has not implemented render()');
}

=item render_text($text)

Render some plain text. All contiguous whitespce will be collased to a single
space (in particular, newlines etc will not be honored). Leading and trailing
white space I<is> relevant.

=cut

sub render_text {
    my ($self, $text) = @_;
    my $width = $self->{width};
    my $lines = $self->{lines};
    my $line_pos = $self->{line_pos};
    my $pos = $self->{pos};
    my $line = $self->{line};
    my $llen = $self->{llen};
    my $indent = $self->{indent};
    my $indent_once = $self->{indent_once};
    my $space = ($llen > 0) ? $self->{space} : 1;
    # We want to know if there's leading or trailing space, so we split thusly:
    my @words = split(/\s+/, $text, -1);

    if ($indent_once) {
        $indent_once = 0 if ($llen > 0);
        $self->{indent_once} = 0;
    }

    foreach my $word (@words) {
        my $wlen = length($word);

        if ($wlen == 0) { # Leading (or trailing) space
            $space = 1;
            next;
        } elsif ($space == 0) {
            if ($llen > 0) {
                # No leading space, no space after last word, so this word is
                # actually part of the last word!
                my $pos = rindex($line, ' ');

                if ($pos < 0) {
                    $word = $line . $word;
                    $wlen += $llen;
                    $line = '';
                    $llen = 0;
                } else {
                    $word = substr($line, $pos + 1) . $word;
                    $wlen += $llen - ($pos + 1);
                    $line = substr($line, 0, $pos);
                    $llen = $pos;
                }
            }

            $space = 1;
        } else {
            $pos++; # Actually a new word!
        }

        # TODO replace this section with clever hyphenation!
        if (($llen > 0) && ($llen + $wlen) >= $width) {
            # This word won't fit on the current (non-empty) line
            push(@{$lines}, $line);
            push(@{$line_pos}, $pos);
            $line = '';
            $llen = 0;
        }

        while ($wlen > $width) {
            # If the word is to big to fit, we split it!
            push(@{$lines}, substr($word, 0, $width, ''));
            push(@{$line_pos}, $pos);
            $wlen -= $width;
        }

        if ($llen == 0) {
            if ($indent || $indent_once) {
                my $i = $indent + $indent_once;

                $indent_once = 0;
                $i = ($width - $wlen) if (($i + $wlen) > $width);
                $line = (' ' x $i) . $word;
                $llen = $i + $wlen;
            } else {
                $line = $word;
                $llen = $wlen;
            }
        } else {
            $line .= ' ' if ($space);
            $line .= $word;
            $llen += 1 + $wlen;
        }
    }

    $self->{pos} = $pos;
    $self->{line} = $line;
    $self->{llen} = $llen;
    $self->{space} = (@words && ($words[$#words] eq '')) ? 1 : 0;
}

=item render_raw_text($text)

Render some raw text. Whitespace will not be collapsed, and newlines will be
homored.

=cut

sub render_raw_text {
    my ($self, $text) = @_;
    my $width = $self->{width};
    my $lines = $self->{lines};
    my $line_pos = $self->{line_pos};
    my $pos = $self->{pos};
    my $line = $self->{line};
    my $llen = $self->{llen};
    my $last = ' ';

    foreach my $char (split(//, $text)) {
        my $newline = 0;

        if ($char eq "\r") {
            $newline = 1;
        } elsif ($char eq "\n") {
            $newline = ($last ne "\r");
        } else {
            $pos++ if (($last =~ /^\s$/) && ($char =~ /^\S$/));
            $line .= $char;
            $llen++;
            $newline = 1 if ($llen >= $width);
        }

        $last = $char;

        if ($newline) {
            push(@{$lines}, $line);
            push(@{$line_pos}, $pos);
            $line = '';
            $llen = 0;
        }
    }

    $self->{pos} = $pos;
    $self->{line} = $line;
    $self->{llen} = $llen;
    $self->{space} = 0;
}

=item newline($extra)

Start a new line if not already on one. If $extra = 1, add a blank line if
already on a new line. If $extra = 2, add a blank line even if not already on
a new line. This will never create two consecutive blank lines, nor a blank
line at the start of the document.

=cut

sub newline {
    my ($self, $extra) = @_;
    my $lines = $self->{lines};
    my $line_pos = $self->{line_pos};

    if ($self->{llen} > 0) {
        push(@{$lines}, $self->{line});
        push(@{$line_pos}, $self->{pos});
        $self->{line} = '';
        $self->{llen} = 0;
        $extra-- if ($extra);
    }

    if ($extra) {
        my $last = $#{$lines};

        if (($last >= 0) && ($lines->[$last] ne '')) {
            push(@{$lines}, '');
            push(@{$line_pos}, $self->{pos});
        }
    }

    $self->{indent_once} = 0;
}

=item add_line($line [, $before [, $after]])

Add a raw line. If longer than the format width, it will be truncated. Set
$before and/or $after to true to ensure empty lines around the inserted line.

=cut

sub add_line {
    my ($self, $line, $before, $after) = @_;
    my $width = $self->{width};

    $line = substr($line, 0, $width) if (length($line) > $width);

    $self->newline($before ? 2 : 0);
    push(@{$self->{lines}}, $line);
    push(@{$self->{line_pos}}, $self->{pos});
    $self->newline($1) if ($after);
}

=back

=item add_anchor($id)

Add an anchor with the given ID at the current line.

=cut

sub add_anchor {
    my ($self, $id) = @_;

    $self->{anchors}{$id} = $self->{pos};
}

=head1 SEE ALSO

L<Ember::Format>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
