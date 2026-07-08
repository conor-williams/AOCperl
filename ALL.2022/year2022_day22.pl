#!/usr/bin/perl
use strict;
use warnings;

my $DAY = 22;

my @DIRS = (
    [0, 1],     # R
    [1, 0],     # D
    [0, -1],    # L
    [-1, 0]     # U
);


sub key {
    my ($r, $c) = @_;
    return "$r,$c";
}


# ---------------- PARSE ----------------

sub parse {

    my ($data) = @_;

    my ($grid_txt, $path_txt) = split(/\n\n/, $data);


    my %grid;

    my @lines = split(/\n/, $grid_txt);


    for my $r (0 .. $#lines) {

        my @chars = split(//, $lines[$r]);


        for my $c (0 .. $#chars) {

            my $ch = $chars[$c];

            if ($ch ne " ") {

                $grid{key($r,$c)} = $ch;
            }
        }
    }


    my @path = ($path_txt =~ /\d+|[LR]/g);


    return (\%grid, \@path);
}



# ---------------- TURN ----------------

sub turn {

    my ($d, $t) = @_;

    if ($t eq "L") {

        return ($d - 1) % 4;

    } else {

        return ($d + 1) % 4;
    }
}



# ---------------- PART 1 WRAP ----------------

sub wrap_flat {

    my ($grid, $r, $c, $d) = @_;


    my ($dr, $dc) = @{$DIRS[$d]};


    my $rr = $r;
    my $cc = $c;


    while (exists $grid->{key($rr-$dr, $cc-$dc)}) {

        $rr -= $dr;
        $cc -= $dc;
    }


    return ($rr, $cc, $d);
}

# ---------------- SIMULATION ----------------

sub simulate {

    my ($grid, $path, $wrap_fn) = @_;


    my $top = 999999;


    for my $pos (keys %$grid) {

        my ($r, $c) = split(/,/, $pos);

        if ($r < $top) {
            $top = $r;
        }
    }



my ($start_r,$start_c);


my @starts;


for my $pos (keys %$grid) {

    my ($r,$c) = split(/,/,$pos);

    if ($r == $top && $grid->{$pos} eq ".") {
        push @starts, [$r,$c];
    }
}


@starts = sort {
       $a->[0] <=> $b->[0]
    || $a->[1] <=> $b->[1]
} @starts;


($start_r,$start_c) = @{$starts[0]};

    my ($r, $c) = ($start_r, $start_c);

    my $d = 0;



    for my $cmd (@$path) {


        if ($cmd eq "L" || $cmd eq "R") {

            $d = turn($d, $cmd);
            next;
        }



        for (1 .. int($cmd)) {


            my ($nr, $nc, $nd) =
                $wrap_fn->($grid, $r, $c, $d);



            if (exists $grid->{key($nr,$nc)}
                && $grid->{key($nr,$nc)} eq "#") {

                last;
            }


            ($r, $c, $d) = ($nr, $nc, $nd);
        }
    }


    return ($r, $c, $d);
}





# ---------------- PART 2 (CORRECT CUBE FOR AoC INPUT) ----------------

my $FACE = 50;



sub wrap_cube {

    my ($grid, $r, $c, $d) = @_;
    #print("ENTER WRAP_CUBE r=$r c=$c d=$d\n");


    my ($dr, $dc) = @{$DIRS[$d]};


    die "BAD POSITION r=$r c=$c d=$d\n"
        unless defined $r && defined $c;
    my $nr = $r + $dr;
    my $nc = $c + $dc;
    #if (!exists $grid->{$nr}{$nc}) {
    #    print "CUBE EDGE: r=$r c=$c d=$d -> nr=$nr nc=$nc\n";
    #}



    if (exists $grid->{key($nr,$nc)}) {

        return ($nr, $nc, $d);
    }



    my $fr = int($r / $FACE);
    my $fc = int($c / $FACE);

    my $ir = $r % $FACE;
    my $ic = $c % $FACE;



    # ---------------- REAL AO CUBE MAP ----------------



    if ($d == 0) {   # RIGHT


        if ($fr == 0 && $fc == 2) {

            return (
                $FACE * 3 - 1 - $ir,
                $FACE * 2 - 1,
                2
            );
        }


        if ($fr == 1 && $fc == 1) {

            return (
                $FACE - 1,
                $FACE * 2 + $ir,
                3
            );
        }


        if ($fr == 2 && $fc == 1) {

            return (
                $FACE * 3 - 1 - $ir,
                $FACE * 2 - 1,
                2
            );
        }


        if ($fr == 3 && $fc == 0) {

            return (
                $FACE - 1,
                $FACE + $ir,
                3
            );
        }
    }



    if ($d == 2) {   # LEFT


        if ($fr == 0 && $fc == 1) {

            return (
                $FACE + $ir,
                0,
                0
            );
        }


        if ($fr == 1 && $fc == 1) {

            return (
                $FACE * 2,
                $ir,
                1
            );
        }


        if ($fr == 2 && $fc == 0) {

            return (
                $FACE * 3 - 1 - $ir,
                $FACE,
                0
            );
        }


        if ($fr == 3 && $fc == 0) {

            return (
                0,
                $FACE + $ir,
                0
            );
        }
    }

    if ($d == 3) {   # UP


        if ($fr == 0 && $fc == 1) {

            return (
                $FACE + $ic,
                $FACE,
                0
            );
        }


        if ($fr == 0 && $fc == 2) {

            return (
                $FACE * 4 - 1,
                $ic,
                3
            );
        }


        if ($fr == 1 && $fc == 1) {

            return (
                $FACE,
                $FACE + $ic,
                0
            );
        }


        if ($fr == 3 && $fc == 0) {

            return (
                $FACE * 3 + $ic,
                $FACE,
                0
            );
        }
    }



    if ($d == 1) {   # DOWN


        if ($fr == 0 && $fc == 2) {

            return (
                $FACE + $ic,
                $FACE * 2 - 1,
                2
            );
        }


        if ($fr == 2 && $fc == 1) {

            return (
                $FACE * 3 - 1,
                $FACE + $ic,
                2
            );
        }


        if ($fr == 3 && $fc == 0) {

            return (
                0,
                $FACE + $ic,
                1
            );
        }


        if ($fr == 3 && $fc == 1) {

            return (
                $FACE,
                $FACE + $ic,
                1
            );
        }
    }


    return ($nr, $nc, $d);
}





# ---------------- PARTS ----------------

sub part1 {

    my ($data) = @_;

    my ($grid, $path) = @$data;


    my ($r, $c, $d) =
        simulate($grid, $path, \&wrap_flat);
    #print("FINAL", $r, , " ", $c, " ", $d);


    return 1000 * ($r + 1)
         + 4 * ($c + 1)
         + $d;
}



sub part2 {

    my ($data) = @_;

    my ($grid, $path) = @$data;


    my ($r, $c, $d) =
        simulate($grid, $path, \&wrap_cube);

    #print("PART2 FINAL r=$r c=$c d=$d\n");

    return 1000 * ($r + 1)
         + 4 * ($c + 1)
         + $d;
}





# ---------------- MAIN ----------------

sub main {

    open(my $fh, "<", $ARGV[0])
        or die "Cannot open $ARGV[0]: $!";


    local $/;

    my $data = <$fh>;

    close($fh);



    my $parsed = [ parse($data) ];


    my $ans1 = part1($parsed);

    my $ans2 = part2($parsed);



    print "2022 day$DAY: pl_ans_1: $ans1\n";
    print("2022 day22: pl_ans_2: TODO\n");
    #print "2022 day$DAY: pl_ans_2: $ans2\n";
}


main();
