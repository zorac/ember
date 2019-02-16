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

use Scalar::Util qw( weaken );
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

=head2 Instance Methods

=over

=item _open()

Open an EPUB book and parse its metadata.

=cut

sub _open {
    my ($self) = @_;
    my $vfs = $self->{vfs};
    my $mime = $vfs->content('mimetype');

    return 0 if ($mime !~ /application\/epub\+zip/i);

    my $container = $vfs->content('META-INF/container.xml');
    my($opf_file, $root_path) = ($container =~ /full-path="((.*?)[^\/]+?)"/);
    my $opf_raw = $vfs->content($opf_file);
    my $opf = XMLin($opf_raw);
    my %items = %{$opf->{manifest}{item}};
    my @refs = @{$opf->{spine}{itemref}};
    my(%manifest, @chapters, $prev);

    foreach my $id (keys(%items)) {
        $manifest{$id} = {
            id      => $id,
            file    => $items{$id}{href},
            mime    => $items{$id}{'media-type'},
        };
    }

    foreach my $ref (@refs) {
        my $chapter = Ember::EPUB::Chapter->new();
        my $id = $ref->{idref};
        my $item = $manifest{$id};
        my $skip = $ref->{linear} && ($ref->{linear} eq 'no');

        $chapter->{id} = $id;
        $chapter->{path} = $item->{file};
        $chapter->{mime} = $item->{mime};
        $chapter->{skip} = 1 if ($skip);
        weaken($chapter->{book} = $self);

        if ($prev) {
            weaken($chapter->{prev} = $prev);
            weaken($prev->{next} = $chapter);
        }

        $prev = $chapter;
        push(@chapters, $chapter);
    }

    # TODO parse metadata, TOC, etc

    $self->{manifest} = \%manifest;
    $self->{chapters} = \@chapters;
    $self->{rootpath} = $root_path;
    $self->{formatter} = Ember::Format::HTML->new();

    return 1;
}

=back

=head1 SEE ALSO

L<Ember::Book>, L<Ember::EPUB::Chapter>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
