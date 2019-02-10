#!/usr/bin/perl

package Ember::VFS::Zip;

use strict;
use warnings;
use base qw( Ember::VFS );
use fields qw( zip members );

use Archive::Zip;

sub _open {
    my ($self) = @_;
    my $filename = $self->{filename};

    return 0 if (!-f $filename);

    eval {
        my $zip = Archive::Zip->new($filename);
        my %members;

        foreach my $member ($zip->memberNames()) {
            $members{$member} = 1;
        }

        $self->{zip} = $zip;
        $self->{members} = \%members;
    };

    return $self->{members} ? 1 : 0;
}

sub content {
    my ($self, $path) = @_;

    return unless ($self->{members}{$path});
    return $self->{zip}->contents($path);
}

1;
