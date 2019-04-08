package Ember::Util;

=head1 NAME

Ember::Util - Utility functions for Ember.

=head1 DESCRIPTION

This class contains utility functions used by various other classes.

=cut

use 5.008;
use strict;
use warnings;
use base qw( Exporter );

# These modules are dynamically loaded:
# use HTML::TreeBuilder 5 -weak;
# use JSON;
# use XML::Simple qw( :strict );

our @EXPORT_OK = qw( get_class html_parse json_parse json_generate
    xml_parse xml_parse_file xml_generate );
our ($HTML, $JSON, $XML);

=head2 Exported Methods

=over

=item get_class([$type [, $name]])

Fetch the Ember class with the given type and name, loading the module if
needed.

=cut

sub get_class {
    my $file = 'Ember';
    my $class = 'Ember';

    foreach my $part (@_) {
        $file .= '/' . $part;
        $class .= '::' . $part;
    }

    require "$file.pm";

    return $class;
}

=item html_parse($html)

Parse HTML text into a DOM tree. Returns an HTML::Element.

=cut

sub html_parse {
    if (!defined($HTML)) {
        require 'HTML/TreeBuilder.pm';

        HTML::Element->Use_Weak_Refs(1);

        $HTML = 1;
    }

    my $tree = HTML::TreeBuilder->new();

    # TODO implicit_body_p_tag? p_strict?
    $tree->ignore_unknown(0);
    $tree->store_declarations(0);
    $tree->parse_content($_[0]);
    $tree->elementify(); # is now an HTML::Element
    $tree->delete_ignorable_whitespace();
    $tree->simplify_pres();
    $tree->number_lists();

    return $tree;
}

=item _json()

Return a JSON encoder/decoder.

=cut

sub _json {
    if (!defined($JSON)) {
        require 'JSON.pm';

        $JSON = JSON->new()->utf8()->indent()->space_after();
    }

    return $JSON;
}

=item json_parse($json)

Parse the given JSON text and return a Perl object.

=cut

sub json_parse {
    my ($json) = @_;

    return unless (defined($json) && ($json ne ''));
    return _json()->decode($json); # TODO error handling
}

=item json_generate($object)

Generate JSON text corresponsing to a given Perl object.

=cut

sub json_generate {;
    return _json()->encode($_[0]); # TODO error handling
}


=item _xml()

Return a XML encoder/decoder.

=cut

sub _xml {
    if (!defined($XML)) {
        require 'XML/Simple.pm';

        $XML = XML::Simple->new(
            ContentKey      => '_',
            ForceArray      => 1,
            ForceContent    => 1,
            KeyAttr         => [],
            NormaliseSpace  => 2,
        );
    }

    return $XML;
}

=item xml_parse($xml)

Parse the given XML text and return a Perl object.

=cut

sub xml_parse {
    my ($xml) = @_;

    return unless (defined($xml) && ($xml ne ''));
    return _xml()->parse_string($xml); # TODO error handling
}

=item xml_parse_file($path)

Parse the given XML file and return a Perl object.

=cut

sub xml_parse_file {
    return _xml()->parse_file($_[0]); # TODO error handling
}

=item xml_generate($object)

Generate XML text corresponsing to a given Perl object.

=cut

sub xml_generate {
    return _xml()->encode($_[0]); # TODO error handling
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
