#!/usr/bin/perl
use strict;
use warnings;

use List::Util qw(min max);

my $DAY = 23;


my %DIRS = (
    "N"  => [-1, 0],
    "S"  => [ 1, 0],
    "W"  => [ 0,-1],
    "E"  => [ 0, 1],
    "NW" => [-1,-1],
    "NE" => [-1, 1],
    "SW" => [ 1,-1],
    "SE" => [ 1, 1],
);


my @CHECKS = (
    ["N", ["N", "NE", "NW"]],
    ["S", ["S", "SE", "SW"]],
    ["W", ["W", "NW", "SW"]],
    ["E", ["E", "NE", "SE"]],
);



sub key {
    my ($r, $c) = @_;
    return "$r,$c";
}


sub parse {
    my ($data) = @_;

    my %elves;

    my $r = 0;

    for my $line (split(/\n/, $data =~ s/^\s+|\s+$//gr)) {

        my $c = 0;

        for my $ch (split(//, $line)) {

            if ($ch eq "#") {
                $elves{key($r,$c)} = 1;
            }

            $c++;
        }

        $r++;
    }

    return \%elves;
}



sub neighbors {
    my ($r, $c) = @_;

    my @result;

    for my $dir (values %DIRS) {
        my ($dr, $dc) = @$dir;
        push @result, [$r + $dr, $c + $dc];
    }

    return @result;
}



sub propose {
    my ($elves, $r, $c, $order) = @_;

    # If no adjacent elves, don't move
    for my $n (neighbors($r, $c)) {
        my ($nr, $nc) = @$n;

        if (exists $elves->{key($nr,$nc)}) {
            goto HAS_NEIGHBOR;
        }
    }

    return undef;

HAS_NEIGHBOR:


    for my $check (@$order) {

        my ($dir_name, $checks) = @$check;

        my $ok = 1;

        for my $d (@$checks) {

            my ($dr, $dc) = @{$DIRS{$d}};

            if (exists $elves->{key($r+$dr,$c+$dc)}) {
                $ok = 0;
                last;
            }
        }

        if ($ok) {
            my ($dr, $dc) = @{$DIRS{$dir_name}};

            return [$r + $dr, $c + $dc];
        }
    }

    return undef;
}



sub simulate {
    my ($elves, $part2) = @_;

    my @order = map { [$_->[0], [@{$_->[1]}]] } @CHECKS;

    my $round_num = 0;


    while (1) {

        my %proposals;
        my %targets;


        # ---- propose ----

        for my $pos (keys %$elves) {

            my ($r, $c) = split(/,/, $pos);

            my $dest = propose($elves, $r, $c, \@order);

            if ($dest) {

                my ($dr, $dc) = @$dest;

                $proposals{$pos} = [$dr, $dc];

                $targets{key($dr,$dc)}++;
            }
        }


        my %new_elves;
        my $moved = 0;


        # ---- apply moves ----

        for my $pos (keys %$elves) {

            my ($r, $c) = split(/,/, $pos);

            if (exists $proposals{$pos}) {

                my $dest = $proposals{$pos};

                my ($dr, $dc) = @$dest;

                if ($targets{key($dr,$dc)} == 1) {

                    $new_elves{key($dr,$dc)} = 1;
                    $moved = 1;

                } else {

                    $new_elves{$pos} = 1;
                }

            } else {

                $new_elves{$pos} = 1;
            }
        }


        $elves = \%new_elves;


        # rotate order
        my $first = shift @order;
        push @order, $first;


        $round_num++;


        # ---- PART 1 STOP CONDITION ----

        if (!$part2 && $round_num == 10) {
            return $elves;
        }


        # ---- PART 2 STOP CONDITION (KEY FIX) ----

        if ($part2 && !$moved) {
            return $round_num;
        }
    }
}



sub score {
    my ($elves) = @_;

    my (@rows, @cols);

    for my $pos (keys %$elves) {
        my ($r, $c) = split(/,/, $pos);

        push @rows, $r;
        push @cols, $c;
    }

    my $min_r = min(@rows);
    my $max_r = max(@rows);
    my $min_c = min(@cols);
    my $max_c = max(@cols);

    return ($max_r - $min_r + 1)
         * ($max_c - $min_c + 1)
         - scalar(keys %$elves);
}



sub part1 {
    my ($elves) = @_;

    my $final = simulate({%$elves}, 0);

    return score($final);
}



sub part2 {
    my ($elves) = @_;

    return simulate({%$elves}, 1);
}



sub main {

    if (@ARGV < 1) {
        print "Usage: perl script.pl input.txt\n";
        exit 1;
    }


    open(my $fh, "<", $ARGV[0])
        or die "Cannot open $ARGV[0]: $!";


    local $/;
    my $input = <$fh>;

    close($fh);


    my $elves = parse($input);


    my $ans1 = part1($elves);
    my $ans2 = part2($elves);


    print "2022 day$DAY: pl_ans_1: $ans1\n";
    print "2022 day$DAY: pl_ans_2: $ans2\n";
}


main();
