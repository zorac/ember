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
use fields qw( spaced in_header in_list );

use Ember::Util qw( html_parse );

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
    dd          => 1,
    dl          => 1, # TODO handle lists
    dt          => 1,
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
    li          => 1,
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
    h1  => '=',
    h2  => '-',
    h3  => '~',
    h4  => '"',
    h5  => "'",
    h6  => '`',
);

=back

=head2 Fields

=over

=item spaced

If set, output blank lines between paragraphs instead of indenting.

=item in_header

Indicates that we're in a header, to avoid double-underlining.

=item in_header

Indicates that we're in a list, to control spacing.

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
    my $tree = html_parse($input);

    $self->{in_header} = 0;
    $self->{in_list} = 0;

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
    my $tag = $element->tag();
    my $id = $element->id();
    my $indent = 0;
    my ($hchar, $sline, $is_list);

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
        $self->{in_header} = 1;
    } elsif ($tag eq 'head') {
        return;
    } elsif ($tag eq 'li') {
        my $bullet = $element->{_bullet} . ' ';

        $self->newline(0);
        $self->render_text($bullet);
        $indent = length($bullet);
    } elsif (($tag eq 'dl') || ($tag eq 'ol') || ($tag eq 'ul')) {
        $self->newline($self->{in_list} ? 0 : 2);
        $self->{in_list}++;
        $is_list = 1;
    } elsif ($tag eq 'dt') {
        $self->newline(0);
    } elsif ($tag eq 'dd') {
        $self->newline(0);
        $indent = 2;
    } elsif ($tag eq 'pre') {
        $self->newline(2);
        $self->render_pre($element);
        $self->newline(2);
        return;
    } elsif ($BLOCK{$tag}) {
        $self->newline($spaced);

        if (!$spaced) {
            my $last = $#{$lines};

            if (($last >= 0) && ($lines->[$last] ne '')) {
                $self->{indent_once} = 2;
            }
        }
    } # TODO a, pre, blockquote, lists, etc

    $element->normalize_content();
    $self->add_anchor($id) if ($id);
    $self->{indent} += $indent if ($indent);

    foreach my $child ($element->content_list()) {
        if (ref($child)) {
            $self->render_element($child);
        } else {
            $self->render_text($child);
        }
    }

    $self->{indent} -= $indent if ($indent);

    if ($hchar && $self->{in_header}) { # Underline a heading
        $self->newline();

        for (my $i = $#{$lines}; $i >= $sline; $i--) {
            splice(@{$lines}, $i + 1, 0, $hchar x length($lines->[$i]));
            splice(@{$line_pos}, $i + 1, 0, $line_pos->[$i]);
        }

        $self->newline(1);
        delete($self->{in_header});
    } elsif ($is_list) {
        $self->{in_list}--;
        $self->newline($self->{in_list} ? 0 : 2);
    } elsif ($BLOCK{$tag}) {
        $self->newline($spaced);
    }
}

=item render_pre($element)

Render the given element in a preformatted text block.

=cut

sub render_pre {
    my ($self, $element) = @_;

    foreach my $child ($element->content_list()) {
        if (ref($child)) {
            my $tag = $child->tag();

            if ($tag eq 'br') {
                $self->newline(1);
            } elsif ($BLOCK{$tag}) {
                $self->newline(0);
                $self->render_pre($child);
                $self->newline(0);
            } else {
                $self->render_pre($child);
            }
        } else {
            $self->render_raw_text($child);
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
