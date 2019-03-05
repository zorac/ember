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

=head2 Class Methods

=over

=item new($opf)

Create a new OPF metadata object, given a hashref of parsed OPF XML.

=cut

sub new {
    my ($class, $opf) = @_;
    my $self = $class->SUPER::new();
    my $format = Ember::Format::HTML->new(999999); # We just want text
    my %metadata;

    $self->parse(\%metadata, $opf->{metadata}{meta});
    $self->parse(\%metadata, $opf->{metadata});

    $self->{title} = $metadata{title}[0]{content}
        if ($metadata{title});
    $self->{title_sort} = $metadata{title_sort}[0]{content}
        if ($metadata{title_sort});
    $self->{series} = $metadata{series}[0]{content}
        if ($metadata{series});
    $self->{series_index} = 0 + $metadata{series_index}[0]{content}
        if ($metadata{series_index});
    $self->{publisher} = $metadata{publisher}[0]{content}
        if ($metadata{publisher});
    $self->{generator} = $metadata{generator}[0]{content}
        if ($metadata{generator});
    $self->{language} = $metadata{language}[0]{content}
        if ($metadata{language});
    $self->{copyright} = $metadata{rights}[0]{content}
        if ($metadata{rights});

    if ($metadata{creator}) {
        $self->{authors} = [ map { $_->{content} } @{$metadata{creator}} ];
        $self->{author_sort} = $metadata{creator}[0]{'file-as'}
            if ($metadata{creator}[0]{'file-as'});
    }

    if ($metadata{date} && ($metadata{date}[0]{content} =~ /^([^T]+)/)) {
        $self->{date} = $1 unless ($1 eq '0101-01-01');
    }

    if ($metadata{description}) {
        my @lines = $format->lines($metadata{description}[0]{content});

        $self->{description} = join("\n", @lines);
    }

    if ($metadata{identifier}) {
        $self->{ids} = { map {
            ($_->{scheme} || $_->{id} || 'id') => $_->{content}
        } @{$metadata{identifier}} };
    }

    # use Data::Dumper; $Data::Dumper::Indent = 1; die Dumper($self);
    # TODO parse more metadata, TOC, etc
    # dc:identifier (multi,opf:scheme)
    # dc:relation?
    # dc:subject?
    # dc:source?
    # dc:coverage?

    return $self;
}

=back

=head2 Instance Methods

=over

=item parse($out, $in)

Extract metadata from parsed XML.

=cut

sub parse {
    my ($self, $out, $in) = @_;
    my $ref = ref($in);

    if ($ref eq 'ARRAY') {
        $in = { map {
            ($_->{name} || $_->{property}) => $_
        } @{$in} };
    } elsif ($ref ne 'HASH') {
        return;
    }

    foreach my $key (keys(%{$in})) {
        my $value = $in->{$key};
        my $ref = ref($value);

        next if (($ref eq 'HASH') && !%{$value});
        $key =~ /^([^:]+)(?::([^:]+))?/;
        next if (($1 eq 'meta') || ($1 eq 'xmlns')
            || ($2 && ($2 eq 'user_metadata')));
        $key = $2 ? $2 : $1;

        my @values = ($ref eq 'ARRAY') ? @{$value} : ($value);

        for (my $i = 0; $i < @values; $i++) {
            if (ref($values[$i]) eq 'HASH') {
                foreach my $subkey (keys(%{$values[$i]})) {
                    if ($subkey =~ /^(.+):(.+)$/) {
                        $values[$i]{$2} = $values[$i]{$subkey}
                            if ($1 ne 'xmlns');
                        delete($values[$i]{$subkey});
                    }
                }
            } else {
                $values[$i] = { content => $values[$i] };
            }
        }

        $out->{$key} = \@values;
    }
}

=back

=head1 SEE ALSO

L<Ember::Metadata>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
