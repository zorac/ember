package Ember::Format::HTML;

=head1 NAME

Ember::Format::HTML - HTML conversion and formatting.

=head1 DESCRIPTION

This formatter converts HTML files into plain text.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Format );
use fields qw( width lines line llen space hlen );

use HTML::TreeBuilder 5 -weak;

=head2 Constants

=over

=item %BLOCK

Hash indicating HTML tags which should be treated as blocks rather than inline.

=cut

our %BLOCK = (
    address     => 1,
    applet      => 1,
    blockquote  => 1,
    div         => 1,
    dl          => 1, # TODO handle lists
    fieldset    => 1,
    figure      => 1,
    embed       => 1,
    form        => 1, # TODO anything?
    iframe      => 1,
    noscript    => 1,
    object      => 1,
    ol          => 1, # TODO handle lists
    p           => 1,
    pre         => 1, # TODO neds proper handling
    table       => 1, # TODO if/how to handle these
    ul          => 1, # TODO handle lists
);

=item %HEADER

Mapping of HTML header tags to the character used to underline them.

=cut

our %HEADER = (
    h1 => '=',
    h2 => '-',
    h3 => '~',
    h4 => '"',
    h5 => "'",
    h6 => '`'
);

=back

=head2 Fields

=over

=item width

The width text should be formatted to fit in.

=item lines

The formatted lines of text during formatting.

=item line

The current line of text during formatting.

=item llen

The length of the current line of text during formatting.

=item space

0 or 1 depending on if we have a space to carry forward.

=item hlen

The length of a heading being processed.

=back

=head2 Instance Methods

=over

=item format($width, $input)

Format HTML text into an array of lines with a given maximum length.

=cut

sub format {
    my ($self, $width, $input) = @_;
    my $tree = HTML::TreeBuilder->new();
    my @lines;

    $self->{width} = $width;
    $self->{lines} = \@lines;
    $self->{line} = '';
    $self->{llen} = 0;
    $self->{space} = 0;

    # TODO implicit_body_p_tag? p_strict?
    $tree->ignore_unknown(0);
    $tree->store_declarations(0);
    $tree->parse_content($input);
    undef($input);

    $tree->elementify(); # is now an HTML::Element
    $tree->delete_ignorable_whitespace();
    $tree->simplify_pres();
    $tree->number_lists();

    $self->process($tree);
    $self->newline();

    undef($self->{lines});
    undef($self->{line});
    undef($self->{llen});

    while ($lines[$#lines] eq '') {
        pop(@lines);
    }

    return @lines;
}

=item process($node)

Pocess a DOM node (an HTML::Element, or plain text).

=cut

sub process {
    my ($self, $node) = @_;
    my $width = $self->{width};
    my $hchar;

    if (ref($node)) {
        my $tag = $node->tag();

        if ($BLOCK{$tag}) {
            $self->newline(1);
        } elsif ($tag eq 'img') {
            my $text = $node->attr('alt'); # TODO or title?

            $text = '[Image]' if (!defined($text));

            $self->process($text);

            return;
        } elsif ($tag eq 'br') {
            $self->newline(1);
            return;
        } elsif ($tag eq 'hr') {
            $self->newline(1);
            push(@{$self->{lines}}, '-' x $width, '');
            return;
        } elsif ($hchar = $HEADER{$tag}) {
            $self->{hlen} = 0;
        } elsif ($tag eq 'head') {
            return;
        } # TODO a, pre, blockquote, lists, etc

        $node->normalize_content();

        foreach my $child ($node->content_list()) {
            $self->process($child);
        }

        if ($hchar) {
            my $hlen = $self->{hlen};

            undef($self->{hlen});
            $hlen = $width if ($hlen > $width);
            $self->newline();
            push(@{$self->{lines}}, $hchar x $hlen, '');
        }

        return;
    }

    my $line = $self->{line};
    my $llen = $self->{llen};
    my $space = ($llen > 0) ? $self->{space} : 1;
    # We want to know if there's leading or trailing space, so we split thusly:
    my @words = split(/\s+/, $node, -1);

    $self->{hlen} += length($node) if (defined($self->{hlen}));

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
        }

        # TODO replace this section with clever hyphenation!
        if (($llen > 0) && ($llen + $wlen) >= $width) {
            # This word won't fit on the current (non-empty) line
            push(@{$self->{lines}}, $line);
            $line = '';
            $llen = 0;
        }

        while ($wlen > $width) {
            # If the word is to big to fit, we split it!
            push(@{$self->{lines}}, substr($word, 0, $width, ''));
            $wlen -= $width;
        }

        if ($llen == 0) {
            $line = $word;
            $llen = $wlen;
        } else {
            $line .= ' ' if ($space);
            $line .= $word;
            $llen += 1 + $wlen;
        }
    }

    $self->{line} = $line;
    $self->{llen} = $llen;
    $self->{space} = (@words && ($words[$#words] eq '')) ? 1 : 0;
}

=item newline($empty)

Start a new line if not already on one. if $empty is set, add a blank line if
the last line was not blank.

=cut

sub newline { # TODO tweak this behaviour
    my ($self, $empty) = @_;

    if ($self->{llen} > 0) {
        push(@{$self->{lines}}, $self->{line});
        $self->{line} = '';
        $self->{llen} = 0;
    }

    if ($empty) {
        my $last = $#{$self->{lines}};

        push(@{$self->{lines}}, '')
            if (($last >= 0) && ($self->{lines}[$last] ne ''));
    }
}

=back

=head1 SEE ALSO

L<Ember::Format>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
