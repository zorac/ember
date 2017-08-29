#!/usr/bin/perl

package Ember::Config;

use strict;
use warnings;
use fields qw( dir );

use Ember::Config::MacOS; # TODO dynamic loading

sub new {
    my ($self) = @_;

    $self = fields::new($self) unless (ref($self));

    return $self if ($self->_open());
}

sub open {
    if ($^O eq 'darwin') {
        return Ember::Config::MacOS->new();
    } elsif ($^O eq 'MSWin32') {
        return Ember::Config::Windows->new();
    } else {
        return Ember::Config::UNIX->new();
    }
}

sub _open {
    die('Cannot directly instantiate Ember::Config');
}

sub get_pos {
    my ($self, $filename) = @_;
    my $file = $self->{dir} . '/position.txt';

    return unless (-e $file);

    CORE::open(IN, '<', $file);

    while (defined(my $line = <IN>)) {
        if ($line =~ /^$filename\t(.+?)\t(\d+)$/) {
            my %result = ( chapter => $1, pos => $2 );
            close(IN);
            return %result;
        }
    }

    close(IN);

    return;
}

sub save_pos {
    my ($self, $reader) = @_;
    my $file = $self->{dir} . '/position.txt';
    my $tmp = $self->{dir} . '/position.tmp';
    my $filename = $reader->{book}{filename};

    CORE::open(IN, '<', $file);
    CORE::open(OUT, '>', $tmp);
    # TODO PI line endings?
    print OUT $filename, "\t", $reader->{chapter}{path}, "\t", $reader->{pos}, "\n";

    while (defined(my $line = <IN>)) {
        print OUT $line unless ($line =~ /^$filename\t/);
    }

    close(OUT);
    close(IN);

    unlink($file);
    rename($tmp, $file);
}

# To implement in subclasses:
# _open() -> bool

1;
