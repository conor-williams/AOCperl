#!/usr/bin/perl
use strict;
use warnings;


# ----------------------------
# Simple Min Heap
# ----------------------------

sub heap_push {
    my ($heap, $item) = @_;

    push @$heap, $item;

    my $i = $#$heap;

    while ($i > 0) {
        my $p = int(($i - 1) / 2);

        last if $heap->[$p][0] <= $heap->[$i][0];

        ($heap->[$p], $heap->[$i]) =
        ($heap->[$i], $heap->[$p]);

        $i = $p;
    }
}


sub heap_pop {
    my ($heap) = @_;

    my $result = $heap->[0];

    my $last = pop @$heap;

    if (@$heap) {

        $heap->[0] = $last;

        my $i = 0;

        while (1) {

            my $left  = $i * 2 + 1;
            my $right = $i * 2 + 2;
            my $small = $i;

            if ($left < @$heap &&
                $heap->[$left][0] < $heap->[$small][0]) {
                $small = $left;
            }

            if ($right < @$heap &&
                $heap->[$right][0] < $heap->[$small][0]) {
                $small = $right;
            }

            last if $small == $i;

            ($heap->[$i], $heap->[$small]) =
            ($heap->[$small], $heap->[$i]);

            $i = $small;
        }
    }

    return $result;
}


# ----------------------------
# Opposite direction
# ----------------------------

sub opposite {
    my ($a, $b) = @_;

    return 1 if $a eq "r" && $b eq "l";
    return 1 if $a eq "l" && $b eq "r";
    return 1 if $a eq "u" && $b eq "d";
    return 1 if $a eq "d" && $b eq "u";

    return 0;
}


# ----------------------------
# Solve
# ----------------------------

sub solve {

    my ($file, $part2) = @_;

    open(my $fh, "<", $file) or die $!;

    my @grid;

    while (<$fh>) {
        chomp;
        push @grid, $_ if length($_);
    }

    close($fh);


    my $h = scalar @grid;
    my $w = length($grid[0]);


    my %dirs = (
        r => [0,1],
        d => [1,0],
        l => [0,-1],
        u => [-1,0],
    );


    my @heap;

    heap_push(
        \@heap,
        [0,0,0,"r",0]
    );


    if ($part2) {
        heap_push(
            \@heap,
            [0,0,0,"d",0]
        );
    }


    my %seen;


    while (@heap) {

        my $node = heap_pop(\@heap);

        my ($heat,$x,$y,$dir,$steps) = @$node;


        my $key = "$x,$y,$dir,$steps";

        next if exists $seen{$key}
             && $seen{$key} <= $heat;

        $seen{$key} = $heat;


        foreach my $nd (keys %dirs) {

            my ($dx,$dy) = @{$dirs{$nd}};

            my $nx = $x + $dx;
            my $ny = $y + $dy;


            next if $nx < 0 || $nx >= $h;
            next if $ny < 0 || $ny >= $w;


            # cannot reverse
            next if opposite($nd,$dir);


            my $nsteps;

            if ($nd eq $dir) {
                $nsteps = $steps + 1;
            }
            else {
                $nsteps = 1;
            }


            if ($part2) {

                next if $nd eq $dir && $steps == 10;

                next if $steps < 4 && $nd ne $dir;

            }
            else {

                next if $nd eq $dir && $steps == 3;

            }


            my $cost = int(substr($grid[$nx],$ny,1));

            my $newheat = $heat + $cost;


            my $nkey = "$nx,$ny,$nd,$nsteps";


            if (!exists $seen{$nkey} ||
                $newheat < $seen{$nkey}) {

                heap_push(
                    \@heap,
                    [
                        $newheat,
                        $nx,
                        $ny,
                        $nd,
                        $nsteps
                    ]
                );
            }
        }
    }


    my $answer = 1e99;


    foreach my $k (keys %seen) {

        my ($x,$y,$d,$s) = split(/,/, $k);

        if ($x == $h-1 && $y == $w-1) {

            if ($seen{$k} < $answer) {
                $answer = $seen{$k};
            }
        }
    }


    return $answer;
}



# ----------------------------
# Main
# ----------------------------

my $file = $ARGV[0];

print "2023 day17: pl_ans_1: ",
      solve($file,0),
      "\n";

print "2023 day17: pl_ans_2: ",
      solve($file,1),
      "\n";
