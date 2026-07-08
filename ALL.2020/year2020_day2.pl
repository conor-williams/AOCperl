#!/usr/bin/perl
use strict;
use warnings;

my $file = shift @ARGV;

open(my $fh, "<", $file) or die "Cannot open $file: $!";

my @lines;

while (<$fh>) {
    chomp;
    push @lines, $_;
}

close($fh);

# -----------------------------------------
# Part 1
# -----------------------------------------

my $total1 = 0;

for my $line (@lines) {

    my @parts = split /\s+/, $line;

    my ($lo, $hi) = split /-/, $parts[0];

    my $ch = substr($parts[1], 0, 1);

    my $pw = $parts[2];

    my $cnt = () = ($pw =~ /\Q$ch\E/g);

    if ($cnt >= $lo && $cnt <= $hi) {
        $total1++;
    }
}

# -----------------------------------------
# Part 2
# -----------------------------------------

my $total2 = 0;

for my $line (@lines) {

    my @parts = split /\s+/, $line;

    my ($a, $b) = split /-/, $parts[0];

    my $ch = substr($parts[1], 0, 1);

    my $pw = $parts[2];

    my $ok1 = substr($pw, $a - 1, 1) eq $ch;
    my $ok2 = substr($pw, $b - 1, 1) eq $ch;

    if ($ok1 != $ok2) {
        $total2++;
    }
}

print "2020 day2: pl_ans_1: $total1\n";
print "2020 day2: pl_ans_2: $total2\n";
