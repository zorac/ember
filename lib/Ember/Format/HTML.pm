package Ember::Format::HTML;

=head1 NAME

Ember::Format::HTML - HTML conversion and formatting.

=head1 DESCRIPTION

This format converts HTML files into plain text.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Format::Document );
use fields;

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

=head2 Instance Methods

=over

=item render($input)

Parse an HTML document, and render it to plain text.

=cut

sub render {
    my ($self, $input) = @_;
    my $tree = HTML::TreeBuilder->new();

    # TODO implicit_body_p_tag? p_strict?
    $tree->ignore_unknown(0);
    $tree->store_declarations(0);
    $tree->parse_content($input);
    $tree->elementify(); # is now an HTML::Element
    $tree->delete_ignorable_whitespace();
    $tree->simplify_pres();
    $tree->number_lists();

    $self->render_element($tree);
}

=item render_element($element)

Render an HTML::Element.

=cut

sub render_element {
    my ($self, $element) = @_;
    my $width = $self->{width};
    my $lines = $self->{lines};
    my $line_pos = $self->{line_pos};
    my ($hchar, $sline);

    my $tag = $element->tag();

    if ($BLOCK{$tag}) {
        $self->newline(2);
    } elsif ($tag eq 'img') {
        my $text = $element->attr('alt'); # TODO or title?

        $text = '[Image]' if (!defined($text));
        $self->render_text($text);
        return;
    } elsif ($tag eq 'br') {
        $self->newline(1);
        return;
    } elsif ($tag eq 'hr') {
        $self->add_line('-' x $width, 1, 1);
        return;
    } elsif ($hchar = $HEADER{$tag}) {
        $self->newline(2);
        $sline = @{$lines};
    } elsif ($tag eq 'head') {
        return;
    } # TODO a, pre, blockquote, lists, etc

    $element->normalize_content();

    foreach my $child ($element->content_list()) {
        if (ref($child)) {
            $self->render_element($child);
        } else {
            $self->render_text($child);
        }
    }

    if ($hchar) { # Underline a heading
        $self->newline();

        for (my $i = $#{$lines}; $i >= $sline; $i--) {
            splice(@{$lines}, $i + 1, 0, $hchar x length($lines->[$i]));
            splice(@{$line_pos}, $i + 1, 0, $line_pos->[$i]);
        }
    }
}

=back

=head1 SEE ALSO

L<Ember::Format>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
