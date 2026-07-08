#!/usr/bin/perl
use strict;
use warnings;


sub priority {

    my ($c) = @_;

    if ($c ge 'a' && $c le 'z') {
        return ord($c) - ord('a') + 1;
    }

    return ord($c) - ord('A') + 27;
}


my $file = $ARGV[0] or die "usage: perl year2022_day3.pl input.txt\n";

open(my $fh, "<", $file) or die "$!\n";


my @lines;

while (<$fh>) {
    chomp;

    push @lines, $_ if $_ ne "";
}

close($fh);


# Part 1

my $p1 = 0;

for my $s (@lines) {

    my $mid = int(length($s) / 2);

    my $a = substr($s, 0, $mid);
    my $b = substr($s, $mid);


    my %left;

    for my $c (split //, $a) {
        $left{$c}=1;
    }


    my %common;

    for my $c (split //, $b) {
        $common{$c}=1 if exists $left{$c};
    }


    for my $c (keys %common) {
        $p1 += priority($c);
    }
}



# Part 2

my $p2 = 0;


for (my $i=0; $i<@lines; $i+=3) {

    my %a = map { $_ => 1 } split //, $lines[$i];
    my %b = map { $_ => 1 } split //, $lines[$i+1];

    my %common;

    for my $c (keys %a) {
        if (exists $b{$c}) {
            $common{$c}=1;
        }
    }


    my %final;

    for my $c (keys %common) {
        if (index($lines[$i+2],$c) >= 0) {
            $final{$c}=1;
        }
    }


    for my $c (keys %final) {
        $p2 += priority($c);
    }
}


print "2022 day3: pl_ans_1: $p1\n";
print "2022 day3: pl_ans_2: $p2\n";
