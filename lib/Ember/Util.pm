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
# use JSON;
# use XML::Simple qw( :strict );

our @EXPORT = qw( get_class json_decode json_encode xml_decode xml_decode_file
    xml_encode );
our ($JSON, $XML);

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

=item json_decode($json)

Decode the given JSON text and return a Perl object.

=cut

sub json_decode {
    my ($json) = @_;

    return unless (defined($json) && ($json ne ''));
    return _json()->decode($json); # TODO error handling
}

=item json_encode($object)

Encode the given Perl objectand return JSON text.

=cut

sub json_encode {;
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

=item xml_decode($xml)

Decode the given XML text and return a Perl object.

=cut

sub xml_decode {
    my ($xml) = @_;

    return unless (defined($xml) && ($xml ne ''));
    return _xml()->parse_string($xml); # TODO error handling
}

=item xml_decode_file($path)

Decode the given XML file and return a Perl object.

=cut

sub xml_decode_file {
    return _xml()->parse_file($_[0]); # TODO error handling
}

=item xml_encode($object)

Encode the given Perl objectand return XML text.

=cut

sub xml_encode {
    return _xml()->encode($_[0]); # TODO error handling
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
