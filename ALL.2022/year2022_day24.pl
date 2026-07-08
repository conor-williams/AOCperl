#!/usr/bin/perl
use strict;
use warnings;

use List::Util qw(first);


my @DIRS = (
    [0, 1],    # R
    [1, 0],    # D
    [0, -1],   # L
    [-1, 0]    # U
);



sub key {
    my ($r, $c) = @_;
    return "$r,$c";
}


# ---------------- PARSE ----------------

sub parse {
    my ($data) = @_;

    my @grid = split(/\n/, $data);

    my %walls;
    my @blizzards;

    my $R = scalar(@grid);
    my $C = length($grid[0]);


    for my $r (0 .. $R-1) {

        my @chars = split(//, $grid[$r]);

        for my $c (0 .. $C-1) {

            my $ch = $chars[$c];

            if ($ch eq "#") {

                $walls{key($r,$c)} = 1;

            } elsif ($ch =~ /[>v<^]/) {

                push @blizzards, [$r, $c, $ch];
            }
        }
    }


    return (\@grid, \%walls, \@blizzards, $R, $C);
}



# ---------------- BLIZZARD MOVEMENT ----------------

sub move {
    my ($blizzards, $R, $C) = @_;

    my @new;


    for my $b (@$blizzards) {

        my ($r, $c, $d) = @$b;


        if ($d eq ">") {

            my $nc = $c + 1;

            if ($nc == $C - 1) {
                $nc = 1;
            }

            push @new, [$r, $nc, $d];


        } elsif ($d eq "<") {

            my $nc = $c - 1;

            if ($nc == 0) {
                $nc = $C - 2;
            }

            push @new, [$r, $nc, $d];


        } elsif ($d eq "v") {

            my $nr = $r + 1;

            if ($nr == $R - 1) {
                $nr = 1;
            }

            push @new, [$nr, $c, $d];


        } elsif ($d eq "^") {

            my $nr = $r - 1;

            if ($nr == 0) {
                $nr = $R - 2;
            }

            push @new, [$nr, $c, $d];
        }
    }


    return \@new;
}



# ---------------- PRECOMPUTE BLIZZARD STATES ----------------

sub precompute {
    my ($blizzards, $R, $C) = @_;

    my $cycle = ($R - 2) * ($C - 2);

    my @states;

    my $cur = $blizzards;


    for (1 .. $cycle) {

        my %occupied;

        for my $b (@$cur) {

            my ($r, $c, undef) = @$b;

            $occupied{key($r,$c)} = 1;
        }


        push @states, \%occupied;

        $cur = move($cur, $R, $C);
    }


    return (\@states, $cycle);
}



# ---------------- BFS ----------------

sub bfs {
    my ($start, $goal, $start_time,
        $states, $cycle, $R, $C, $walls) = @_;


    my @q;

    my %seen;


    push @q, [$start->[0], $start->[1], $start_time];


    while (@q) {

        my $current = shift @q;

        my ($r, $c, $t) = @$current;


        if ($r == $goal->[0] && $c == $goal->[1]) {
            return $t;
        }


        my $seen_key = key($r,$c) . "," . ($t % $cycle);

        next if exists $seen{$seen_key};

        $seen{$seen_key} = 1;


        my $next_blizz = $states->[($t + 1) % $cycle];


        # wait + move

        my @moves = (@DIRS, [0,0]);


        for my $m (@moves) {

            my ($dr, $dc) = @$m;

            my $nr = $r + $dr;
            my $nc = $c + $dc;


            # allow goal even if boundary

            if ($nr == $goal->[0] && $nc == $goal->[1]) {
                return $t + 1;
            }


            # bounds

            next if exists $walls->{key($nr,$nc)};

            next if $nr < 0 || $nc < 0 ||
                    $nr >= $R || $nc >= $C;


            next if exists $next_blizz->{key($nr,$nc)};


            push @q, [$nr, $nc, $t + 1];
        }
    }


    return -1;
}




# ---------------- SOLVE ----------------

sub solve {
    my ($data) = @_;


    my ($grid, $walls, $blizzards, $R, $C) =
        parse($data);


    my $start_c = index($grid->[0], ".");

    my $goal_c = index($grid->[-1], ".");


    my $start = [0, $start_c];

    my $goal = [$R - 1, $goal_c];


    my ($states, $cycle) =
        precompute($blizzards, $R, $C);



    # trip 1: start -> goal

    my $t1 =
        bfs($start, $goal, 0,
            $states, $cycle, $R, $C, $walls);



    # trip 2: goal -> start

    my $t2 =
        bfs($goal, $start, $t1,
            $states, $cycle, $R, $C, $walls);



    # trip 3: start -> goal

    my $t3 =
        bfs($start, $goal, $t2,
            $states, $cycle, $R, $C, $walls);


    return ($t1, $t3);
}




# ---------------- MAIN ----------------

sub main {

    open(my $fh, "<", $ARGV[0])
        or die "Cannot open $ARGV[0]: $!";


    local $/;

    my $data = <$fh>;

    close($fh);


    $data =~ s/^\s+|\s+$//g;


    my ($a, $b) = solve($data);


    print "2022 day24: pl_ans_1: $a\n";
    print "2022 day24: pl_ans_2: $b\n";
}


main();
