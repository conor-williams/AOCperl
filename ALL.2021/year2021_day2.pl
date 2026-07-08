#!/usr/bin/perl
use strict;
use warnings;

my $path = $ARGV[0];

my $x = 0;
my $depth = 0;

my $aim = 0;
my $x2 = 0;
my $depth2 = 0;


open my $fh, "<", $path or die "$path: $!";


while (<$fh>) {

    chomp;

    next unless $_ =~ /\S/;

    my @parts = split /\s+/;

    my $cmd = $parts[0];
    my $val = int($parts[1]);


    # ----------------
    # Part 1
    # ----------------

    if ($cmd eq "forward") {

        $x += $val;

    } elsif ($cmd eq "down") {

        $depth += $val;

    } elsif ($cmd eq "up") {

        $depth -= $val;
    }


    # ----------------
    # Part 2
    # ----------------

    if ($cmd eq "forward") {

        $x2 += $val;
        $depth2 += $aim * $val;

    } elsif ($cmd eq "down") {

        $aim += $val;

    } elsif ($cmd eq "up") {

        $aim -= $val;
    }
}


close $fh;


my $ans1 = $x * $depth;
my $ans2 = $x2 * $depth2;


print "2021 day2: pl_ans_1: $ans1\n";
print "2021 day2: pl_ans_2: $ans2\n";
