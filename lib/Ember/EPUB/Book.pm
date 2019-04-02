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

use Carp;

use Ember::EPUB::Chapter;
use Ember::Metadata::OPF;
use Ember::TOC::NCX;
use Ember::TOC::Spine;

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

Open an EPUB book and parse its metadata.

=cut

sub new {
    my ($class, $args) = @_;
    my $vfs = $args->{vfs};
    my $mime = $vfs->read_text('mimetype');

    croak('Missing MIME type') if (!$mime);
    croak("Inavlid MIME type for EPUB: $mime")
        if ($mime !~ /application\/(epub|x-ibooks)\+zip/i); # TODO

    my $self = $class->SUPER::new($args);
    my $container = $vfs->read_xml('META-INF/container.xml');
    my $opf_file = $container->{rootfiles}[0]{rootfile}[0]{'full-path'};
    my ($root_path) = ($opf_file =~ /^(.*?)[^\/]*$/);
    my $opf = $vfs->read_xml($opf_file);
    my $spine = $opf->{spine}[0];
    my (%manifest, $toc, @chapters, $prev);

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

        $toc = Ember::TOC::NCX->new($ncx);
    } else {
        $toc = Ember::TOC::Spine->new($spine);
    }

    foreach my $ref (@{$spine->{itemref}}) {
        my $id = $ref->{idref};
        my $item = $manifest{$id};
        my $skip = $ref->{linear} && ($ref->{linear} eq 'no');
        my $chapter = Ember::EPUB::Chapter->new({
            id      => $id,
            path    => $item->{file},
            mime    => $item->{mime},
            skip    => $skip,
            book    => $self,
            prev    => $prev,
        });

        $prev = $chapter;
        push(@chapters, $chapter);
    }

    # TODO <guide>

    $self->{metadata}   = Ember::Metadata::OPF->new($opf);
    $self->{toc}        = $toc;
    $self->{manifest}   = \%manifest;
    $self->{chapters}   = \@chapters;
    $self->{rootpath}   = $root_path;

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
