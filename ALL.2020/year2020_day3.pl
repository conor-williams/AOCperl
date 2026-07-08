#!/usr/bin/perl
use strict;
use warnings;

sub count_trees {

    my ($grid, $dx, $dy) = @_;

    my $x = 0;
    my $y = 0;

    my $h = scalar(@$grid);
    my $w = length($grid->[0]);

    my $trees = 0;

    while ($y < $h) {

        if (substr($grid->[$y], $x % $w, 1) eq "#") {
            $trees++;
        }

        $x += $dx;
        $y += $dy;
    }

    return $trees;
}

my $file = shift @ARGV;

open(my $fh, "<", $file) or die "Cannot open $file: $!";

my @grid;

while (<$fh>) {
    chomp;
    next if $_ eq "";
    push @grid, $_;
}

close($fh);

# -----------------------------------------
# Part 1
# -----------------------------------------

my $p1 = count_trees(\@grid, 3, 1);

# -----------------------------------------
# Part 2
# -----------------------------------------

my @slopes = (
    [1,1],
    [3,1],
    [5,1],
    [7,1],
    [1,2],
);

my $p2 = 1;

for my $s (@slopes) {

    my ($dx, $dy) = @$s;

    $p2 *= count_trees(\@grid, $dx, $dy);
}

print "2020 day3: pl_ans_1: $p1\n";
print "2020 day3: pl_ans_2: $p2\n";
