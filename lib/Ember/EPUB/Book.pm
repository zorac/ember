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
use Ember::Metadata::OPF;

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
    my(%manifest, %titles, @chapters, $prev);

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

    $self->{metadata} = Ember::Metadata::OPF->new($opf);
    $self->{manifest} = \%manifest;
    $self->{chapters} = \@chapters;
    $self->{rootpath} = $root_path;
    $self->{formatter} = $formatter;

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
