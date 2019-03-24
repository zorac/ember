package Ember::App::SearchFilter;

=head1 NAME

Ember::App::SearchFilter - An app for filtering search results.

=head1 DESCRIPTION

This is the first half of the search app: filtering results.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::App );
use fields qw( terms ids metadata );

use Ember::Format::KeyValue;

=head2 Fields

=over

=item terms

The search terms which have been entered.

=item ids

The IDs of the search results.

=item metadata

Cached metadata for visible search results.

=back

=head2 Class Methods

=over

=item new($args)

Create a new table of contents viewer. Settable fields: terms (optional).

=cut

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);

    $self->{terms} = '';
    $self->{ids} = [];
    $self->{metadata} = [];

    $self->set_terms($args->{terms});

    return $self;
}

=back

=head2 Instance Methods

=over

=item set_terms()

Set the current search terms.

=cut

sub set_terms {
    my ($self, $terms) = @_;

    $terms = '' if (!defined($terms));
    $self->footer("Search for: $terms", 1);
    return if ($terms eq $self->{terms});
    $self->{terms} = $terms;

    my @ids = sort { $a <=> $b } $self->{config}->search($terms);
    my $old = join(',', @{$self->{ids}});
    my $new = join(',', @ids);

    return if ($old eq $new);

    $self->{ids} = \@ids;
    $self->{metadata} = [];
    $self->layout(1, 1);
    $self->render();
}

=item fetch_metadata($count)

Ensure metadata is avilable for the first I<$count> search results.

=cut

sub fetch_metadata {
    my ($self, $count) = @_;
    my $ids = $self->{ids};
    my $metadata = $self->{metadata};
    my $config = $self->{config};

    $count = @{$ids} if ($count > @{$ids});

    for (my $i = @{$metadata}; $i < $count; $i++) {
        my ($title, $authors) = $config->get_metadata($ids->[$i], 'title',
            'authors');

        $metadata->[$i] = [
            $title || 'Unknown',
            @{$authors} ? join(' & ', @{$authors}) : 'Unknown'
        ];
    }
}

=item layout($width_changed, $height_changed)

Fetch any additional metadata which might be required.

=cut

sub layout {
    my ($self, $width_changed, $height_changed) = @_;

    $self->fetch_metadata($self->{height} - 1) if ($height_changed);
}

=item render()

Render the page at the current reading position.

=cut

sub render {
    my ($self) = @_;
    my $metadata = $self->{metadata};
    my $rows = $self->{height} - 1;
    my $count = $rows;
    my $table = Ember::Format::KeyValue->new($self->{width});

    $count = @{$metadata} if ($count > @{$metadata});

    my @input = @{$metadata}[0 .. ($count - 1)];
    my @lines = $table->lines(\@input);

    @lines = @lines[0 .. ($rows - 1)] if (@lines > $rows);

    $self->{screen}->clear_screen();
    print join("\n", @lines);
    $self->footer();
}

=item keypress($key)

Handle keypresses to perform item selection.

=cut

sub keypress {
    my ($self, $key) = @_;
    my $terms = $self->{terms};

    if ($key =~ /^[0-9A-Za-z ]$/) {
        $terms = defined($terms) ? "$terms$key" : $key;
        $self->set_terms($terms);
    } elsif ($key eq 'bs') {
        my $len = length($terms);

        if ($len <= 1) {
            $self->set_terms('');
        } else{
            $self->set_terms(substr($terms, 0, $len - 1));
        }
    } elsif ($key eq "\n") {
        my $ids = $self->{ids};
        my $count = @{$self->{ids}};

        if ($count > 0) {
            $self->fetch_metadata($count);

            return 'push', 'SearchSelect', {
                ids => $ids,
                metadata => $self->{metadata}
            };
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
        [ 'A-Z...' => 'Enter search terms' ],
        [ 'Enter' => 'Accept the search terms' ],
        [ 'Escape' => 'Exit search' ],
    );

    return $keys;
}

=back

=head1 SEE ALSO

L<Ember::App::Pager>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
