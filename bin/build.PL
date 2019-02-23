#!/usr/bin/env perl

use 5.008;
use strict;
use warnings;

use File::Slurp qw( read_file edit_file );

my (@modules, $in_deps);

foreach my $line (read_file('Makefile.PL')) {
    if ($line =~ /PREREQ_PM/) {
        $in_deps = 1;
    } elsif ($in_deps && ($line =~ /^\s*'(.+?)'/)) {
        push(@modules, $1);
    } elsif ($line =~ /^\s*},$/) {
        $in_deps = 0;
    }
}

my $modules = join(' ', @modules);

edit_file(sub { s/(notest install) qw\(.*?\)/$1 qw( $modules )/ }, $ARGV[0]);
