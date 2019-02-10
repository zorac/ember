#!/usr/bin/perl

package Ember::App;

use strict;
use warnings;

use Cwd qw( realpath );

use Ember::Book;
use Ember::Config;
use Ember::Reader;

sub new {
    my ($this, @args) = @_;
    my $class = ref($this) || $this;
    my $self = {};

    # TODO better arg parsing & usage

    if (@args == 0) {
        die("Usage: ember <ebook_filename>");
    }

    my $filename = realpath($args[0]);

    die('Unable to locate requested file')
        unless ($filename && -e $filename);

    $self->{filename} = $filename;
    $self->{chapter} = $args[1];

    return bless($self, $class);
}

sub run {
    my ($self) = @_;
    my $config = Ember::Config->open();
    my $book = Ember::Book->open($self->{filename});
    my %pos = $self->{chapter} ? ( chapter => $self->{chapter} )
        : $config->get_pos($self->{filename});

    my $reader = Ember::Reader->new($book, $pos{chapter}, $pos{pos});

    binmode(STDOUT, ':utf8');

    $reader->run;
    $config->save_pos($reader);

    # TODO menu, save pos, etc, etc
}

1;
