package Ember::Format::Text;

=head1 NAME

Ember::Format::Text - Text conversion and formatting.

=head1 DESCRIPTION

This format handles plain-text content. It assumes blank lines between
paragraphs.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Format::Document );

=head2 Instance Methods

=over

=item render($input)

Render a plain text document

=cut

sub render {
    my ($self, $input) = @_;

    foreach my $paragraph (split(/\s*\n\s*\n\s*/, $input)) {
        $self->newline(2);
        $self->render_text($paragraph);
    }
}

=back

=head1 SEE ALSO

L<Ember::Format>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
