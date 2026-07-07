#!/usr/bin/perl
use strict;
use warnings;

# -------------------------
# PART 1
# -------------------------

sub solve_part1 {
    my (@lines) = @_;

    my @parsed;
    my $max_depth = 0;

    foreach my $line (@lines) {
        if ($line =~ /(\d+): (\d+)/) {
            my $d = int($1);
            my $r = int($2);

            push @parsed, [$d, $r];

            if ($d > $max_depth) {
                $max_depth = $d;
            }
        }
    }

    my @deq;
    my @direction;

    for (my $i = 0; $i <= $max_depth; $i++) {
        $deq[$i] = [];
        $direction[$i] = 0;
    }

    foreach my $p (@parsed) {
        my ($d, $r) = @$p;

        push @{$deq[$d]}, "S";

        for (my $i = 1; $i < $r; $i++) {
            push @{$deq[$d]}, "N";
        }
    }

    my $total = 0;

    for (my $pos = 0; $pos <= $max_depth; $pos++) {

        if (scalar(@{$deq[$pos]}) != 0 &&
            $deq[$pos][0] eq "S") {

            $total += $pos * scalar(@{$deq[$pos]});
        }


        for (my $ii = 0; $ii <= $max_depth; $ii++) {

            if (scalar(@{$deq[$ii]}) != 0) {

                if ($direction[$ii] == 0) {

                    my $xx = pop @{$deq[$ii]};
                    unshift @{$deq[$ii]}, $xx;

                    if ($deq[$ii][-1] eq "S") {
                        $direction[$ii] = 1;
                    }

                } else {

                    my $xx = shift @{$deq[$ii]};
                    push @{$deq[$ii]}, $xx;

                    if ($deq[$ii][0] eq "S") {
                        $direction[$ii] = 0;
                    }
                }
            }
        }
    }

    print "2017 day13: pl_ans_1: $total\n";
}


# -------------------------
# PART 2
# -------------------------

sub solve_part2 {
    my (@lines) = @_;

    my @parsed;
    my $max_depth = 0;

    foreach my $line (@lines) {

        if ($line =~ /(\d+): (\d+)/) {

            my $d = int($1);
            my $r = int($2);

            push @parsed, [$d, $r];

            if ($d > $max_depth) {
                $max_depth = $d;
            }
        }
    }


    my @deq;
    my @deq_orig;

    my @direction;
    my @direction_orig;


    for (my $i = 0; $i <= $max_depth; $i++) {

        $deq[$i] = [];
        $deq_orig[$i] = [];

        $direction[$i] = 0;
        $direction_orig[$i] = 0;
    }


    foreach my $p (@parsed) {

        my ($d, $r) = @$p;

        push @{$deq[$d]}, "S";
        push @{$deq_orig[$d]}, "S";

        for (my $i = 1; $i < $r; $i++) {

            push @{$deq[$d]}, "N";
            push @{$deq_orig[$d]}, "N";
        }
    }


    my $size = 0;

    while (1) {

        $size++;

        my $found = 0;


        for (my $ii = 0; $ii <= $max_depth; $ii++) {

            if (scalar(@{$deq[$ii]}) != 0) {

                my $len = scalar(@{$deq[$ii]});

                if (($size + $ii) % (($len * 2) - 2) == 0) {

                    $found = 1;
                    last;
                }
            }
        }


        if ($found == 0) {
            last;
        }
    }


    print "2017 day13: pl_ans_2: $size\n";
}


# -------------------------
# MAIN
# -------------------------

open(my $fh, "<", $ARGV[0]) or die "Cannot open file\n";

my @lines;

while (<$fh>) {

    chomp;

    next if $_ eq "";

    push @lines, $_;
}

close($fh);


solve_part1(@lines);
solve_part2(@lines);
