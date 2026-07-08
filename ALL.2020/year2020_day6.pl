#!/usr/bin/perl
use strict;
use warnings;

my $file = shift;

open(my $fh, "<", $file) or die $!;

local $/;
my $text = <$fh>;
close($fh);

$text =~ s/\s+$//;

my @groups = split(/\n\s*\n/, $text);

my ($p1, $p2) = (0, 0);

foreach my $group (@groups) {

    my @people = split(/\s+/, $group);

    # -----------------------
    # Part 1
    # -----------------------
    my %any;

    foreach my $person (@people) {
        $any{$_} = 1 for split //, $person;
    }

    $p1 += scalar(keys %any);

    # -----------------------
    # Part 2
    # -----------------------
    my %all;
    $all{$_} = 1 for split //, $people[0];

    for (my $i = 1; $i < @people; $i++) {

        my %cur;
        $cur{$_} = 1 for split //, $people[$i];

        foreach my $k (keys %all) {
            delete $all{$k} unless exists $cur{$k};
        }
    }

    $p2 += scalar(keys %all);
}

print "2020 day6: pl_ans_1: $p1\n";
print "2020 day6: pl_ans_2: $p2\n";
