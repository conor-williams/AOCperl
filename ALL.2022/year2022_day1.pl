#!/usr/bin/perl
use strict;
use warnings;

my $file = $ARGV[0] or die "usage: perl year2022_day1.pl input.txt\n";

open my $fh, "<", $file or die "$!\n";

my @elves;
my $current = 0;

while (<$fh>) {

    chomp;

    if ($_ eq "") {
        push @elves, $current;
        $current = 0;
    }
    else {
        $current += int($_);
    }
}

push @elves, $current if $current;

close $fh;


@elves = sort { $b <=> $a } @elves;


my $p1 = $elves[0];

my $p2 =
      $elves[0]
    + $elves[1]
    + $elves[2];


print "2022 day1: pl_ans_1: $p1\n";
print "2022 day1: pl_ans_2: $p2\n";
