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

=item new($vfs)

Open an EPUB book and parse its metadata. Returns undefined if the VFS does not
contain an EPUB book.

=cut

sub new {
    my ($class, $vfs) = @_;
    my $mime = $vfs->content('mimetype');

    return undef if (!$mime || ($mime !~ /application\/epub\+zip/i));

    my $self = $class->SUPER::new($vfs);
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
        my $id = $ref->{idref};
        my $item = $manifest{$id};
        my $skip = $ref->{linear} && ($ref->{linear} eq 'no');
        my $chapter = Ember::EPUB::Chapter->new({
            id => $id,
            path => $item->{file},
            mime => $item->{mime},
            skip => $skip,
            book => $self,
            prev => $prev,
        });

        $prev = $chapter;
        push(@chapters, $chapter);
    }

    # TODO parse metadata, TOC, etc

    $self->{manifest} = \%manifest;
    $self->{chapters} = \@chapters;
    $self->{rootpath} = $root_path;
    $self->{formatter} = Ember::Format::HTML->new();

    return $self;
}

=back

=head1 SEE ALSO

L<Ember::Book>, L<Ember::EPUB::Chapter>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
