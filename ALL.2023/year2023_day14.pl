#!/usr/bin/perl
use strict;
use warnings;

my $file = $ARGV[0] or die "Usage: $0 input.txt\n";

open my $fh, "<", $ARGV[0] or die "$!";
my @grid;

while (<$fh>) {
    chomp;
    next if $_ eq "";
    push @grid, $_;
}

close $fh;
my $len = length($grid[0]);

for my $row (@grid) {
    die "BAD ROW LENGTH\n" if length($row) != $len;
}
sub transpose {
    my (@grid) = @_;

    my @out;

    my $h = scalar @grid;
    my $w = length($grid[0]);

    for my $x (0 .. $w - 1) {
        my $line = "";

        for my $y (0 .. $h - 1) {
            $line .= substr($grid[$y], $x, 1);
        }

        push @out, $line;
    }

    return @out;
}

sub tilt {
    my ($grid_ref, $direction, $vec) = @_;

    $direction //= "v";
    $vec //= 1;

    my @grid = @$grid_ref;

    my @g;

    if ($direction eq "v") {
        @g = transpose(@grid);
    } else {
        @g = @grid;
    }


    for my $i (0 .. $#g) {

        my @parts = split /#/, $g[$i], -1;
        my @new;

        for my $part (@parts) {

            my $count = ($part =~ tr/O/O/);
            my $len = length($part);

            my $newpart;

            if ($vec == 1) {
                $newpart = ("O" x $count) . ("." x ($len - $count));
            }
            else {
                $newpart = ("." x ($len - $count)) . ("O" x $count);
            }

            push @new, $newpart;
        }

        $g[$i] = join("#", @new);
    }


    if ($direction eq "v") {
        @g = transpose(@g);
    }

    return @g;
}


sub cycle {
    my (@grid) = @_;

    @grid = tilt(\@grid, "v", 1);
    @grid = tilt(\@grid, "h", 1);
    @grid = tilt(\@grid, "v", -1);
    @grid = tilt(\@grid, "h", -1);

    return @grid;
}


sub calc_load {
    my (@grid) = @_;

    my $sum = 0;
    my $h = scalar @grid;

    for my $i (0 .. $#grid) {
        my $weight = $h - $i;
        my $count = ($grid[$i] =~ tr/O/O/);

        $sum += $weight * $count;
    }

    return $sum;
}


# -------------------------
# Part 1
# -------------------------

my @part1_grid = tilt(\@grid, "v", 1);

my $p1 = calc_load(@part1_grid);

print "2023 day14: pl_ans_1: $p1\n";


# -------------------------
# Part 2
# -------------------------

my @g = @grid;

my %seen;
my @history;

my $target = 1_000_000_000;

my $i = 0;

while ($i < $target) {

    @g = cycle(@g);

    my $key = join("\n", @g);

    if (exists $seen{$key}) {

        my $start = $seen{$key};
        my $cycle_len = $i - $start;

        my $remaining = ($target - 1 - $i) % $cycle_len;

        @g = split /\n/, $history[$start + $remaining];

        last;
    }

    $seen{$key} = $i;
    push @history, $key;

    $i++;
}


my $p2 = calc_load(@g);

print "2023 day14: pl_ans_2: $p2\n";
