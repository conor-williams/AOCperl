#!/usr/bin/perl
use strict;
use warnings;

my $path = $ARGV[0];

open my $fh, "<", $path or die "$path: $!";

my @bits;

while (<$fh>) {
    chomp;
    next unless /\S/;
    push @bits, $_;
}

close $fh;


sub most_common {
    my ($bits, $i) = @_;

    my $ones = 0;

    for my $row (@$bits) {
        $ones++ if substr($row, $i, 1) eq "1";
    }

    my $zeros = scalar(@$bits) - $ones;

    return ($ones >= $zeros) ? "1" : "0";
}


sub least_common {
    my ($bits, $i) = @_;

    my $ones = 0;

    for my $row (@$bits) {
        $ones++ if substr($row, $i, 1) eq "1";
    }

    my $zeros = scalar(@$bits) - $ones;

    return ($ones >= $zeros) ? "0" : "1";
}


sub filter_rating {
    my ($bits, $type) = @_;

    my @arr = @$bits;

    my $i = 0;

    while (scalar(@arr) > 1) {

        my $target;

        if ($type eq "most") {
            $target = most_common(\@arr, $i);
        } else {
            $target = least_common(\@arr, $i);
        }

        @arr = grep {
            substr($_, $i, 1) eq $target
        } @arr;

        $i++;
    }

    return oct("0b" . $arr[0]);
}


my $n = length($bits[0]);

my $gamma = "";
my $epsilon = "";


for my $i (0 .. $n-1) {

    if (most_common(\@bits, $i) eq "1") {
        $gamma .= "1";
        $epsilon .= "0";
    } else {
        $gamma .= "0";
        $epsilon .= "1";
    }
}


my $p1 = oct("0b$gamma") * oct("0b$epsilon");


my $oxy = filter_rating(\@bits, "most");
my $co2 = filter_rating(\@bits, "least");

my $p2 = $oxy * $co2;


print "2021 day3: pl_ans_1: $p1\n";
print "2021 day3: pl_ans_2: $p2\n";
