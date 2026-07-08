#!/usr/bin/perl
use strict;
use warnings;

# Advent of Code 2022 Day 9
# Direct translation of the supplied Python solution.
# Usage:
#   perl year2022_day9.pl input.txt

my $file = shift @ARGV or die "usage: $0 input.txt\n";

# --------------------------------------------------
# Parse one instruction into individual unit steps
# --------------------------------------------------
sub parse_steps {
    my ($line) = @_;
    my ($dir, $count) = split / /, $line;

    my @steps;

    if ($dir eq "R") {
        push @steps, [1,0] for 1..$count;
    }
    elsif ($dir eq "L") {
        push @steps, [-1,0] for 1..$count;
    }
    elsif ($dir eq "U") {
        push @steps, [0,1] for 1..$count;
    }
    elsif ($dir eq "D") {
        push @steps, [0,-1] for 1..$count;
    }

    return @steps;
}

sub read_steps {
    open(my $fh, "<", $file) or die $!;

    my @steps;

    while (<$fh>) {
        chomp;
        next unless length;
        push @steps, parse_steps($_);
    }

    close($fh);
    return @steps;
}

sub touching {
    my ($a, $b) = @_;

    return abs($a->[0] - $b->[0]) <= 1 &&
           abs($a->[1] - $b->[1]) <= 1;
}

sub keep_up {
    my ($lead, $follow) = @_;

    return [ @$follow ] if touching($lead, $follow);

    my $xdiff = $lead->[0] - $follow->[0];
    my $ydiff = $lead->[1] - $follow->[1];

    # same column or longer Y distance
    if ($xdiff == 0 || abs($xdiff) < abs($ydiff)) {
        return [
            $lead->[0],
            $ydiff > 0 ? $lead->[1]-1 : $lead->[1]+1
        ];
    }

    # same row or longer X distance
    if ($ydiff == 0 || abs($xdiff) > abs($ydiff)) {
        return [
            $xdiff > 0 ? $lead->[0]-1 : $lead->[0]+1,
            $lead->[1]
        ];
    }

    # diagonal
    return [
        $xdiff > 0 ? $lead->[0]-1 : $lead->[0]+1,
        $ydiff > 0 ? $lead->[1]-1 : $lead->[1]+1
    ];
}

sub calc_tail_movements {
    my ($steps_ref, $length) = @_;
    $length ||= 2;

    my @rope;

    for (1..$length) {
        push @rope, [0,0];
    }

    my %visited;
    $visited{"0,0"} = 1;

    for my $step (@$steps_ref) {

        # move head
        $rope[0][0] += $step->[0];
        $rope[0][1] += $step->[1];

        # every knot follows previous knot
        for (my $i = 1; $i < @rope; $i++) {
            $rope[$i] = keep_up($rope[$i-1], $rope[$i]);
        }

        my $tail = $rope[-1];
        $visited{"$tail->[0],$tail->[1]"} = 1;
    }

    return scalar(keys %visited);
}

# --------------------------------------------------
# Tests (same as Python)
# --------------------------------------------------
sub keep_up_test {

    my $r;

    $r = keep_up([0,0],[0,0]);    die unless $r->[0]==0 && $r->[1]==0;
    $r = keep_up([0,0],[1,0]);    die unless $r->[0]==1 && $r->[1]==0;
    $r = keep_up([0,0],[0,1]);    die unless $r->[0]==0 && $r->[1]==1;

    $r = keep_up([10,10],[0,10]); die unless $r->[0]==9 && $r->[1]==10;
    $r = keep_up([10,10],[10,0]); die unless $r->[0]==10 && $r->[1]==9;

    $r = keep_up([0,0],[0,10]);   die unless $r->[0]==0 && $r->[1]==1;
    $r = keep_up([0,0],[10,0]);   die unless $r->[0]==1 && $r->[1]==0;

    $r = keep_up([4,3],[2,4]);    die unless $r->[0]==3 && $r->[1]==3;
    $r = keep_up([4,2],[3,0]);    die unless $r->[0]==4 && $r->[1]==1;
}

# --------------------------------------------------
# Main
# --------------------------------------------------

keep_up_test();

my @steps = read_steps();

my $p1 = calc_tail_movements(\@steps, 2);
my $p2 = calc_tail_movements(\@steps, 10);

print "2022 day9: pl_ans_1: $p1\n";
print "2022 day9: pl_ans_2: $p2\n";
