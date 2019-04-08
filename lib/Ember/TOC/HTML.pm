package Ember::TOC::HTML;

=head1 NAME

Ember::TOC::HTML - HTML format table of Contents handling.

=head1 DESCRIPTION

This class handles HTML format tables of contents.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::TOC );

use Ember::Format::HTML;
use Ember::TOC::Entry;
use Ember::Util qw( html_parse );

=head2 Class Methods

=over

=item new($html)

Create a new table of contents from HTML.

=cut

sub new {
    my ($class, $html) = @_;
    my $self = $class->SUPER::new();

    my $tree = html_parse($html);
    my $nav = $tree->look_down( _tag => 'nav', 'epub:type' => 'toc' ); # TODO namespace

    return if (!$nav);

    my $ol = $nav->look_down(_tag => 'ol');

    $self->{entries} = $self->read_list($ol, 0);

    return $self;
}

=back

=head2 Instance Methods

=over

=item read_list($ol, $depth)

Read any anchor and sub-list from the input and return an arrayref of entries.

=cut

sub read_list {
    my ($self, $ol, $depth) = @_;
    my $format = Ember::Format::HTML->new(9999);
    my @entries;

    foreach my $li ($ol->content_list()) {
        if (ref($li) && ($li->tag() eq 'li')) {
            my $entry;

            foreach my $element ($li->content_list()) {
                my $tag = $element->tag();

                if ($tag eq 'ol') {
                    $entry->{children} = $self->read_list($element, $depth + 1);
                } else {
                    my $href = ($tag eq 'a') ? $element->attr('href') : '';
                    my ($chapter, $anchor) = split(/#/, $href);
                    my $title = join(' ', $format->lines($element));

                    $entry = Ember::TOC::Entry->new({
                        chapter     => $chapter,
                        anchor      => $anchor,
                        title       => $title,
                        depth       => $depth,
                    });
                }
            }

            push(@entries, $entry) if ($entry);
        }
    }

    return \@entries;
}

=back

=head1 SEE ALSO

L<Ember::TOC>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
