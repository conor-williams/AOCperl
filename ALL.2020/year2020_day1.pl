#!/usr/bin/perl
use strict;
use warnings;

my $file = shift @ARGV;

open(my $fh, "<", $file) or die $!;

my @nums;

while (<$fh>) {
    chomp;
    next if $_ eq "";
    push @nums, int($_);
}

close($fh);


# ============================================================
# PART 1: two-sum
# ============================================================

my %seen;

my $p1 = undef;

for my $n (@nums) {

    if (exists $seen{2020 - $n}) {

        $p1 = $n * (2020 - $n);
        last;
    }

    $seen{$n}=1;
}



# ============================================================
# PART 2: three-sum
# ============================================================

my $p2 = undef;

my @sorted = sort { $a <=> $b } @nums;


for (my $i=0; $i<@sorted; $i++) {

    my $a=$sorted[$i];

    my $l=$i+1;
    my $r=$#sorted;


    while ($l < $r) {

        my $s =
            $a +
            $sorted[$l] +
            $sorted[$r];


        if ($s == 2020) {

            $p2 =
                $a *
                $sorted[$l] *
                $sorted[$r];

            last;
        }

        elsif ($s < 2020) {
            $l++;
        }

        else {
            $r--;
        }
    }


    last if defined $p2;
}



print "2020 day1: pl_ans_1: $p1\n";
print "2020 day1: pl_ans_2: $p2\n";
