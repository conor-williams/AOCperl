#!/usr/bin/perl
use strict;
use warnings;

# Advent of Code 2022 Day 16
# Part 1

my $file = shift @ARGV or die "input file required\n";

open(my $fh, "<", $file) or die $!;
my @lines = <$fh>;
close($fh);

chomp @lines;


# ------------------------------------------------------------
# Parse
# ------------------------------------------------------------

my %valves;
my %tunnels;

foreach my $line (@lines) {

    next if $line eq "";

    if ($line =~
        /Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/)
    {
        my $name = $1;
        my $rate = int($2);
        my @next = split /,\s*/, $3;

        $valves{$name} = $rate;
        $tunnels{$name} = \@next;
    }
}


# ------------------------------------------------------------
# Useful valves
# ------------------------------------------------------------

my @useful =
    grep { $valves{$_} > 0 }
    keys %valves;

push @useful, "AA";


# ------------------------------------------------------------
# BFS shortest paths
# ------------------------------------------------------------

my %dist;

foreach my $start (@useful) {

    my @queue;
    push @queue, [$start,0];

    my %seen;
    $seen{$start}=1;

    while (@queue) {

        my $item = shift @queue;

        my ($node,$d)=@$item;

        $dist{$start}{$node}=$d;

        foreach my $next (@{$tunnels{$node}}) {

            next if exists $seen{$next};

            $seen{$next}=1;

            push @queue, [$next,$d+1];
        }
    }
}


# ------------------------------------------------------------
# Bit indexes
# ------------------------------------------------------------

my %idx;

my $n=0;

foreach my $v (@useful) {

    next if $v eq "AA";

    $idx{$v}=$n;
    $n++;
}


# ------------------------------------------------------------
# Flow table
# ------------------------------------------------------------

my %flow;

foreach my $v (@useful) {

    $flow{$v}=$valves{$v};
}


# ------------------------------------------------------------
# DFS with memoisation
# ------------------------------------------------------------

my %memo;


sub dfs {

    my ($pos,$time,$mask)=@_;

    my $key="$pos,$time,$mask";

    return $memo{$key}
        if exists $memo{$key};


    my $best=0;


    foreach my $next (keys %idx) {

        my $bit = 1 << $idx{$next};


        # already opened
        next if ($mask & $bit);


        my $travel =
            $dist{$pos}{$next}+1;


        next if $travel >= $time;


        my $remaining =
            $time-$travel;


        my $gain =
            $flow{$next}*$remaining;


        my $score =
            $gain +
            dfs(
                $next,
                $remaining,
                $mask | $bit
            );


        $best=$score if $score>$best;
    }


    $memo{$key}=$best;

    return $best;
}


# ------------------------------------------------------------
# Solve Part 1
# ------------------------------------------------------------

my $answer =
    dfs("AA",30,0);


print "2022 day16: pl_ans_1: $answer\n";
# ------------------------------------------------------------
# Part 2 FAST CORRECT
# ------------------------------------------------------------

my $all_mask = (1 << scalar(keys %idx)) - 1;

my %best;


sub explore2 {

    my ($pos,$time,$mask,$score)=@_;


    if (!exists $best{$mask} || $score > $best{$mask}) {
        $best{$mask} = $score;
    }


    foreach my $next (keys %idx) {

        my $bit = 1 << $idx{$next};

        next if ($mask & $bit);


        my $travel = $dist{$pos}{$next}+1;

        next if $travel >= $time;


        my $remain = $time-$travel;

        my $gain = $flow{$next}*$remain;


        explore2(
            $next,
            $remain,
            $mask | $bit,
            $score + $gain
        );
    }
}


%best=();

explore2(
    "AA",
    26,
    0,
    0
);


# ------------------------------------------------------------
# Complete missing subsets
# ------------------------------------------------------------

my @dp;

for(my $i=0; $i <= $all_mask; $i++) {

    $dp[$i] = $best{$i} // 0;
}


# subset maximum DP
for(my $b=0; $b < scalar(keys %idx); $b++) {

    for(my $mask=0; $mask <= $all_mask; $mask++) {

        if ($mask & (1 << $b)) {

            my $without =
                $mask ^ (1 << $b);

            if ($dp[$without] > $dp[$mask]) {
                $dp[$mask]=$dp[$without];
            }
        }
    }
}


# ------------------------------------------------------------
# You + elephant
# ------------------------------------------------------------

my $part2=0;


for(my $mask=0; $mask <= $all_mask; $mask++) {

    my $elephant =
        $all_mask ^ $mask;


    my $score =
        $dp[$mask] + $dp[$elephant];


    $part2=$score if $score>$part2;
}


print "2022 day16: pl_ans_2: $part2\n";
