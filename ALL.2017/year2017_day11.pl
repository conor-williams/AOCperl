#!/usr/bin/perl

use strict;
use warnings;

sub dist {
    my ($x, $y, $z) = @_;
    return (abs($x) + abs($y) + abs($z)) / 2;
}

my $file = $ARGV[0];

open(my $fh, "<", $file) or die;
my $line = <$fh>;
close($fh);

chomp $line;

my @steps = split(/,/, $line);

my $x = 0;
my $y = 0;
my $z = 0;

my $max_dist = 0;

foreach my $s (@steps) {

    if ($s eq "n") {
        $y += 1;
        $z -= 1;
    }
    elsif ($s eq "s") {
        $y -= 1;
        $z += 1;
    }
    elsif ($s eq "ne") {
        $x += 1;
        $z -= 1;
    }
    elsif ($s eq "sw") {
        $x -= 1;
        $z += 1;
    }
    elsif ($s eq "nw") {
        $x -= 1;
        $y += 1;
    }
    elsif ($s eq "se") {
        $x += 1;
        $y -= 1;
    }

    my $d = dist($x, $y, $z);

    if ($d > $max_dist) {
        $max_dist = $d;
    }
}

my $p1 = dist($x, $y, $z);
my $p2 = $max_dist;

print "2017 day11: pl_ans_1: $p1\n";
print "2017 day11: pl_ans_2: $p2\n";
