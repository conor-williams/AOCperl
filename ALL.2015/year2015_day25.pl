#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw();

open my $fh, '<', $ARGV[0] or die $!;
my $t = <$fh>;
close $fh;

my ($r, $c) = ($t =~ /(\d+)/g);

my $n = ($r + $c - 2) * ($r + $c - 1) / 2 + $c - 1;

my $x = 20151125;

for (1 .. $n) {
    $x = ($x * 252533) % 33554393;
}

print "2015 day25: pl_ans_a: $x\n";
