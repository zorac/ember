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
use fields qw( manifest rootpath );

use Ember::EPUB::Chapter;
use Ember::Metadata::OPF;

=head2 Fields

=over

=item manifest

Stores manifest data from the EPUB file.

=item rootpath

The root path within the EPUB file.

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
    my $mime = $vfs->read_text('mimetype');

    return undef if (!$mime || ($mime !~ /application\/epub\+zip/i));

    my $self = $class->SUPER::new($args);
    my $container = $vfs->read_xml('META-INF/container.xml');
    my $opf_file = $container->{rootfiles}[0]{rootfile}[0]{'full-path'};
    my ($root_path) = ($opf_file =~ /^(.*?)[^\/]*$/);
    my $opf = $vfs->read_xml($opf_file);
    my (%manifest, %titles, @chapters, $prev);

    foreach my $item (@{$opf->{manifest}[0]{item}}) {
        my $id = $item->{id};

        $manifest{$id} = {
            id      => $id,
            file    => $item->{href},
            mime    => $item->{'media-type'},
        };
    }

    if ($opf->{spine}[0]{toc}) {
        my $ncx_file = $root_path . $manifest{$opf->{spine}[0]{toc}}{file};
        my $ncx = $vfs->read_xml($ncx_file);

        foreach my $nav (@{$ncx->{navMap}[0]{navPoint}}) {
            my $src = $nav->{content}[0]{src};
            my $pos = index($src, '#');

            $src = substr($src, 0, $pos) if ($pos > 0);

            $titles{$src} = $nav->{navLabel}[0]{text}[0]{_};
        }
    }

    foreach my $ref (@{$opf->{spine}[0]{itemref}}) {
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

    $self->{metadata} = Ember::Metadata::OPF->new($opf);
    $self->{manifest} = \%manifest;
    $self->{chapters} = \@chapters;
    $self->{rootpath} = $root_path;

    return $self;
}

=back

=head2 Instance Methods

=over

=back

=head1 SEE ALSO

L<Ember::Book>, L<Ember::EPUB::Chapter>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
