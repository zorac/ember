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
use fields qw( spaced );

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
    h1          => 1,
    h2          => 1,
    h3          => 1,
    h4          => 1,
    h5          => 1,
    h6          => 1,
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

=item spaced

If set, output blank lines between paragraphs instead of indenting.

=back

=head2 Class Methods

=over

=item new($width [, $spaced])

Create a new HTML formatter.

=cut

sub new {
    my ($class, $width, $spaced) = @_;
    my $self = $class->SUPER::new($width);

    $self->{spaced} = 1 if ($spaced);

    return $self;
}

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
    my $spaced = $self->{spaced} ? 2 : 0;
    my ($hchar, $sline);

    my $tag = $element->tag();

    if ($tag eq 'img') {
        my $text = $element->attr('alt'); # TODO or title?

        if (defined($text) && ($text ne '')) {
            $self->render_text($text);
        } else {
            my $parent = $element->parent();

            # An image with no alt alone in a block forces a blank line
            $self->newline(2) if ($parent && $BLOCK{$parent->tag()}
                    && ($parent->content_list() == 1));
        }

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
    } elsif ($BLOCK{$tag}) {
        $self->newline($spaced);

        if (!$spaced) {
            my $last = $#{$lines};

            if (($last >= 0) && ($lines->[$last] ne '')) {
                $self->{indent} = 2;
            }
        }
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

        $self->newline(1);
    } elsif ($BLOCK{$tag}) {
        $self->newline($spaced);
    }
}

=back

=head1 SEE ALSO

L<Ember::Format>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
