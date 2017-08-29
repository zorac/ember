#!/usr/bin/perl

use strict;
use warnings;

use Ember::App;

my $app = Ember::App->new(@ARGV);

$app->run();
