#!/usr/bin/perl
use strict;
use warnings;

use Math::BigInt;

my $file = $ARGV[0];

open(my $fh, "<", $file) or die "Cannot open $file\n";

my @hail;

while (<$fh>) {
    chomp;
    next if $_ eq "";

    my ($x,$y,$z,$vx,$vy,$vz) =
        /(-?\d+),\s*(-?\d+),\s*(-?\d+)\s+\@\s+(-?\d+),\s*(-?\d+),\s*(-?\d+)/;

    push @hail, [$x,$y,$z,$vx,$vy,$vz];
}

close($fh);



sub part1 {

    my ($h)=@_;

    my $lo=200000000000000;
    my $hi=400000000000000;

    my $ans=0;


    for my $i (0..$#$h-1) {
        for my $j ($i+1..$#$h) {

            my ($x1,$y1,undef,$vx1,$vy1,undef)=@{$h->[$i]};
            my ($x2,$y2,undef,$vx2,$vy2,undef)=@{$h->[$j]};


            my $det=$vx1*$vy2-$vy1*$vx2;

            next if $det==0;


            my $dx=$x2-$x1;
            my $dy=$y2-$y1;


            my $t1=($dx*$vy2-$dy*$vx2)/$det;
            my $t2=($dx*$vy1-$dy*$vx1)/$det;


            next if $t1<0 || $t2<0;


            my $ix=$x1+$vx1*$t1;
            my $iy=$y1+$vy1*$t1;


            if ($ix >= $lo && $ix <= $hi &&
                $iy >= $lo && $iy <= $hi) {

                $ans++;
            }
        }
    }

    return $ans;
}




# Gaussian elimination
sub solve_matrix {

    my ($A,$b)=@_;

    my $n=@$b;


    for my $col (0..$n-1) {

        my $pivot=$col;

        for my $r ($col+1..$n-1) {

            if (abs($A->[$r][$col]) >
                abs($A->[$pivot][$col])) {

                $pivot=$r;
            }
        }


        ($A->[$col],$A->[$pivot]) =
        ($A->[$pivot],$A->[$col]);

        ($b->[$col],$b->[$pivot]) =
        ($b->[$pivot],$b->[$col]);


        my $div=$A->[$col][$col];

        for my $c ($col..$n-1) {
            $A->[$col][$c]/=$div;
        }

        $b->[$col]/=$div;



        for my $r (0..$n-1) {

            next if $r==$col;

            my $factor=$A->[$r][$col];

            for my $c ($col..$n-1) {
                $A->[$r][$c]-=
                    $factor*$A->[$col][$c];
            }

            $b->[$r]-=
                $factor*$b->[$col];
        }
    }


    return @$b;
}



sub part2 {

    my ($h)=@_;


    my @A;
    my @B;


    # build equations from pairs
    for my $pair ([0,1],[0,2],[0,3]) {

        my ($a,$b)=@$pair;


        my ($x1,$y1,$z1,$vx1,$vy1,$vz1)=@{$h->[$a]};
        my ($x2,$y2,$z2,$vx2,$vy2,$vz2)=@{$h->[$b]};


        # x/y equation
        push @A, [
            $vy1-$vy2,
            $vx2-$vx1,
            0,
            $y2-$y1,
            $x1-$x2,
            0
        ];

        push @B,
            $x1*$vy1-$y1*$vx1
            -
            ($x2*$vy2-$y2*$vx2);



        # x/z equation
        push @A, [
            $vz1-$vz2,
            0,
            $vx2-$vx1,
            $z2-$z1,
            0,
            $x1-$x2
        ];

        push @B,
            $x1*$vz1-$z1*$vx1
            -
            ($x2*$vz2-$z2*$vx2);

    }


    my @sol=solve_matrix(\@A,\@B);


    my ($x,$y,$z,$vx,$vy,$vz)=@sol;


    return int($x+$y+$z+0.5);
}




print "2023 day24: pl_ans_1: ", part1(\@hail), "\n";
print "2023 day24: pl_ans_2: ", part2(\@hail), "\n";
