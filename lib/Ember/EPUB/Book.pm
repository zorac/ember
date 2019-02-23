package Ember::EPUB::Book;

=head1 NAME

Ember::EPUB::Book - An EPUB book.

=head1 DESCRIPTION

This class handles EPUB formatted books.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Ember::Book );
use fields qw( manifest rootpath formatter );

use XML::Simple;

use Ember::EPUB::Chapter;
use Ember::Format::HTML;

=head2 Fields

=over

=item manifest

Stores manifest data from the EPUB file.

=item rootpath

The root path within the EPUB file.

=item formatter

The formatter instance used to format chapters.

=back

=head2 Class Methods

=over

=item new($args)

Open an EPUB book and parse its metadata. Returns undefined if the VFS does not
contain an EPUB book.

=cut

sub new {
    my ($class, $args) = @_;
    my $vfs = $args->{vfs};
    my $mime = $vfs->content('mimetype');

    return undef if (!$mime || ($mime !~ /application\/epub\+zip/i));

    my $self = $class->SUPER::new($args);
    my $formatter = Ember::Format::HTML->new();
    my $container = $vfs->content('META-INF/container.xml');
    my($opf_file, $root_path) = ($container =~ /full-path="((.*?)[^\/]+?)"/);
    my $opf_raw = $vfs->content($opf_file);
    my $opf = XMLin($opf_raw);
    my %items = %{$opf->{manifest}{item}};
    my @refs = @{$opf->{spine}{itemref}};
    my(%manifest, %titles, @chapters, $prev, %metain, %metaout);

    foreach my $id (keys(%items)) {
        $manifest{$id} = {
            id      => $id,
            file    => $items{$id}{href},
            mime    => $items{$id}{'media-type'},
        };
    }

    if ($opf->{spine}{toc}) {
        my $ncx_file = $root_path . $manifest{$opf->{spine}{toc}}{file};
        my $ncx_raw = $vfs->content($ncx_file);
        my $ncx = XMLin($ncx_raw);
        my $navs = $ncx->{navMap}{navPoint};

        foreach my $nav (values(%{$navs})) {
            $titles{$nav->{content}{src}} = $nav->{navLabel}{text};
        }
    }

    foreach my $ref (@refs) {
        my $id = $ref->{idref};
        my $item = $manifest{$id};
        my $skip = $ref->{linear} && ($ref->{linear} eq 'no');
        my $chapter = Ember::EPUB::Chapter->new({
            id => $id,
            title => $titles{$item->{file}},
            path => $item->{file},
            mime => $item->{mime},
            skip => $skip,
            book => $self,
            prev => $prev,
        });

        $prev = $chapter;
        push(@chapters, $chapter);
    }

    $self->parse_metadata(\%metain, $opf->{metadata}{meta});
    $self->parse_metadata(\%metain, $opf->{metadata});

    $metaout{title} = $metain{title}[0]{content}
        if ($metain{title});
    $metaout{title_sort} = $metain{title_sort}[0]{content}
        if ($metain{title_sort});
    $metaout{series} = $metain{series}[0]{content}
        if ($metain{series});
    $metaout{series_index} = 0 + $metain{series_index}[0]{content}
        if ($metain{series_index});
    $metaout{publisher} = $metain{publisher}[0]{content}
        if ($metain{publisher});
    $metaout{generator} = $metain{generator}[0]{content}
        if ($metain{generator});
    $metaout{language} = $metain{language}[0]{content}
        if ($metain{language});
    $metaout{copyright} = $metain{rights}[0]{content}
        if ($metain{rights});

    if ($metain{creator}) {
        $metaout{authors} = [ map { $_->{content} } @{$metain{creator}} ];
        $metaout{author_sort} = $metain{creator}[0]{'file-as'}
            if ($metain{creator}[0]{'file-as'});
    }

    if ($metain{date} && ($metain{date}[0]{content} =~ /^([^T]+)/)) {
        $metaout{date} = $1 unless ($1 eq '0101-01-01');
    }

    if ($metain{description}) {
        my @lines = $formatter->format(99999, $metain{description}[0]{content});

        $metaout{description} = join("\n", @lines);
    }

    if ($metain{identifier}) {
        $metaout{ids} = { map {
            ($_->{scheme} || $_->{id} || 'id') => $_->{content}
        } @{$metain{identifier}} };
    }

    # use Data::Dumper; $Data::Dumper::Indent = 1; die Dumper(\%metaout);
    # TODO parse more metadata, TOC, etc
    # dc:identifier (multi,opf:scheme)
    # dc:relation?
    # dc:subject?
    # dc:source?
    # dc:coverage?

    $self->{metadata} = \%metaout;
    $self->{manifest} = \%manifest;
    $self->{chapters} = \@chapters;
    $self->{rootpath} = $root_path;
    $self->{formatter} = $formatter;

    return $self;
}

=back

=head2 Instance Methods

=over

=item parse_metadata($out, $in)

Extract metadata from parsed XML.

=cut

sub parse_metadata {
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

L<Ember::Book>, L<Ember::EPUB::Chapter>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
