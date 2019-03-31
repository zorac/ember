package Ember::Metadata::OPF;

=head1 NAME

Ember::Metadata::OPF - OPF metadata parser.

=head1 DESCRIPTION

This class handles parsing of OPF metadata.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Metadata );

use Ember::Format::HTML;

=head2 Constants

=over

=item %MAP

Mapping from OPF metadata fields to our internal ones.

=cut

our %MAP = (
    'author_sort'   => { field  => 'author_sort',
                         join   => ' & ' },
    'creator'       => { field  => 'authors',
                         extra  => { 'opf:file-as' => 'ember:author_sort' } },
    'date'          => { field  => 'date',
                         format => 'extract_date' },
    'description'   => { field  => 'description',
                         format => 'html2text' },
    'identifier'    => { field  => 'ids',
                         key    => 'id' },
    'language'      => { field  => 'language' },
    'publisher'     => { field  => 'publisher' },
    'rights'        => { field  => 'copyright' },
    'series'        => { field  => 'series' },
    'series_index'  => { field  => 'series_index' },
    'title'         => { field  => 'title' },
    'title_sort'    => { field  => 'title_sort' },
    'generator'     => { field  => 'generator' },
    # dc:contributor?
    # dc:coverage?
    # dc:relation?
    # dc:rightsHolder?
    # dc:subject?
    # dc:source?
);

=head2 Class Methods

=over

=item new($opf)

Create a new OPF metadata object, given a hashref of parsed OPF XML.

=cut

sub new {
    my ($class, $opf) = @_;
    my $self = $class->SUPER::new();

    foreach my $key (keys(%{$opf->{metadata}[0]})) {
        my $values = $opf->{metadata}[0]{$key};

        next if (ref($values) ne 'ARRAY');

        foreach my $value (@{$values}) {
            if ($key eq 'meta') {
                if (defined($value->{property})) {
                    $self->add_metadata($value->{property}, '_', $value);
                } else {
                    $self->add_metadata($value->{name}, 'content', $value);
                }
            } else {
                $self->add_metadata($key, '_', $value);
            }
        }
    }

    if (!defined($self->{title_sort}) && defined($self->{title})) {
        $self->{title_sort} = $self->{title}; # TODO sortify
    }

    if (!defined($self->{author_sort}) && defined($self->{authors})) {
        $self->{title_sort} = join(' & ', @{$self->{authors}}); # TODO sortify
    }

    return $self;
}

=item add_metadata($key, $content_key, $value)

Add an item of metadata.

=cut

sub add_metadata {
    my ($self, $key, $content_key, $value) = @_;

    $key = $1 if ($key =~ /^\S+:(.*)$/);

    my $meta = $MAP{$key};

    return if (!$meta);

    my $field = $meta->{field};
    my $type = $Ember::Metadata::TYPES{$field};
    my $text = $value->{$content_key};

    return if (!defined($text));

    if ($meta->{format}) {
        my $method = $meta->{format};

        $text = $self->$method($text);
        return if (!defined($text));
    }

    if ($type eq 'array') {
        $self->{$field} = [] if (!$self->{$field});

        foreach my $t (@{$self->{$field}}) {
            if ($t eq $text) {
                undef($text);
                last;
            }
        }

        push(@{$self->{$field}}, $text) if (defined($text));
    } elsif ($type eq 'hash') {
        $self->{$field} = {} if (!$self->{$field});
        $self->{$field}{$value->{$meta->{key}}} = $text;
    } elsif (defined($meta->{join}) && defined($self->{$field})) {
        $self->{$field} .= $meta->{join} . $text
            if (index($self->{$field}, $text) < 0); # TODO be less crude
    } else {
        $self->{$field} = $text;
    }

    if ($meta->{extra}) {
        foreach my $ekey (keys(%{$meta->{extra}})) {
            $self->add_metadata($meta->{extra}{$ekey}, $ekey, $value);
        }
    }
}

=item html2text($html)

Convert HTML metadata to plain text.

=cut

sub html2text {
    my ($self, $html) = @_;
    my $format = Ember::Format::HTML->new(999999, 1); # We just want text

    return join("\n", $format->lines($html));
}

=item extract_date($date)

Extract the date from a date/time field.

=cut

sub extract_date {
    my ($self, $date) = @_;

    $date = $1 if ($date =~ /^(\d\d\d\d-\d\d-\d\d)/);
    undef($date) if ($date eq '0101-01-01'); # Calibre bug

    return $date;
}

=back

=head1 SEE ALSO

L<Ember::Metadata>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
