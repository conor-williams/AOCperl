#!/usr/bin/perl
use strict;
use warnings;


open(my $fh,"<",$ARGV[0]) or die "Cannot open file\n";


my $inp = 0;

while (<$fh>) {

    chomp;

    $inp = int($_);
}


close($fh);



# Part 1

my $steps = int($inp);

my @lock = (0);

my $pos = 0;


for (my $i=0; $i<2017; $i++) {


    my $new = ($pos + $steps) % scalar(@lock);

    $new += 1;


    splice(@lock,$new,0,$i+1);


    $pos = $new;
}


print "2017 day17: pl_ans_1: $lock[$pos+1]\n";



# Part 2

my $step = $inp;

my $i = 0;

my $ans = 0;


for (my $t=1; $t<=50000000; $t++) {


    $i = ($i+$step) % $t + 1;


    if ($i == 1) {

        $ans = $t;
    }
}


print "2017 day17: pl_ans_2: $ans\n";
