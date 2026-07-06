#!/usr/bin/env perl
use strict;
use warnings;

my $file = shift @ARGV;
open my $fh, '<', $file or die $!;

my $data = <$fh>;
chomp $data;

my @ins = split /, /, $data;

# N, E, S, W
my @dx = (0, 1, 0, -1);
my @dy = (1, 0, -1, 0);

my ($x, $y) = (0, 0);
my $dir = 0;

my %visited;
$visited{"0,0"} = 1;

my $p2;

for my $ins (@ins) {
    my $turn = substr($ins, 0, 1);
    my $steps = substr($ins, 1);
    $steps = int($steps);

    if ($turn eq 'R') {
        $dir = ($dir + 1) % 4;
    } else {
        $dir = ($dir - 1) % 4;
    }

    for (1..$steps) {
        $x += $dx[$dir];
        $y += $dy[$dir];

        if (!defined $p2) {
            my $key = "$x,$y";
            if ($visited{$key}) {
                $p2 = abs($x) + abs($y);
            }
            $visited{$key} = 1;
        }
    }
}

my $p1 = abs($x) + abs($y);

print "2016 day1: pl_ans_1: $p1\n";
print "2016 day1: pl_ans_2: $p2\n";
