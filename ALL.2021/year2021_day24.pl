#!/usr/bin/perl
use strict;
use warnings;


my $file = $ARGV[0];

open my $fh, "<", $file or die "$!\n";

my @lines = <$fh>;

close $fh;


# remove newlines
chomp @lines;


# --------------------------------------------------
# Extract pairs from the 14 ALU blocks
# line offsets:
# block * 18 + 5
# block * 18 + 15
# --------------------------------------------------

my @pairs;

for my $i (0..13) {

    my $a_line = $lines[$i * 18 + 5];
    my $b_line = $lines[$i * 18 + 15];

    my ($a) = $a_line =~ /(-?\d+)$/;
    my ($b) = $b_line =~ /(-?\d+)$/;

    push @pairs, [
        int($a),
        int($b)
    ];
}



# --------------------------------------------------
# Build digit links
# --------------------------------------------------

my @stack;

my %links;


for my $i (0..13) {

    my ($a,$b)=@{$pairs[$i]};


    if ($a > 0) {

        push @stack, [
            $i,
            $b
        ];

    }
    else {

        my ($j,$bj)=@{pop @stack};

        $links{$i}=[
            $j,
            $bj + $a
        ];
    }
}



# --------------------------------------------------
# Part 1 - maximum model number
# --------------------------------------------------

my %assign;


for my $i (sort {$a <=> $b} keys %links) {

    my ($j,$delta)=@{$links{$i}};


    $assign{$i} =
        (9 < 9 + $delta)
        ? 9
        : 9 + $delta;


    $assign{$i}=9
        if $assign{$i} > 9;

    $assign{$i}=1
        if $assign{$i} < 1;



    $assign{$j} =
        (9 < 9 - $delta)
        ? 9
        : 9 - $delta;


    $assign{$j}=9
        if $assign{$j} > 9;

    $assign{$j}=1
        if $assign{$j} < 1;
}


my $ans1="";

for my $i (0..13) {
    $ans1 .= $assign{$i};
}


print "2021 day24: pl_ans_1: $ans1\n";



# --------------------------------------------------
# Part 2 - minimum model number
# --------------------------------------------------

my %digits;


for my $i (sort {$a <=> $b} keys %links) {

    my ($j,$delta)=@{$links{$i}};


    if ($delta >= 0) {

        $digits{$j}=1;
        $digits{$i}=1+$delta;

    }
    else {

        $digits{$i}=1;
        $digits{$j}=1-$delta;
    }
}


my $ans2="";

for my $i (0..13) {
    $ans2 .= $digits{$i};
}


print "2021 day24: pl_ans_2: $ans2\n";
