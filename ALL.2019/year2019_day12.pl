#!/usr/bin/perl

use strict;
use warnings;


sub gcd {

    my ($a,$b)=@_;

    $a = abs($a);
    $b = abs($b);

    while ($b) {
        ($a,$b)=($b,$a % $b);
    }

    return $a;
}


sub lcm {

    my ($a,$b)=@_;

    return abs($a*$b) / gcd($a,$b);
}


sub parse {

    my $path = $ARGV[0];

    open my $fh,'<',$path or die $!;

    my @pos;

    while (<$fh>) {

        chomp;

        next unless /\S/;

        my @nums =
            /(-?\d+)/g;

        push @pos,\@nums;
    }

    close $fh;

    return \@pos;
}


sub combinations {

    my ($n)=@_;

    my @pairs;

    for my $i (0..$n-2) {

        for my $j ($i+1..$n-1) {

            push @pairs,[$i,$j];
        }
    }

    return \@pairs;
}


sub simulate_axis {

    my ($start)=@_;

    my $n = @$start;

    my @pos=@$start;

    my @vel=(0)x$n;


    my %seen;

    my $steps=0;


    my $pairs =
        combinations($n);


    while (1) {


        my $state =
            join ",",
            @pos,
            "|",
            @vel;


        if (exists $seen{$state}) {

            return $steps;
        }


        $seen{$state}=1;


        # gravity

        for my $p (@$pairs) {

            my ($i,$j)=@$p;


            if ($pos[$i] < $pos[$j]) {

                $vel[$i]++;
                $vel[$j]--;

            }
            elsif ($pos[$i] > $pos[$j]) {

                $vel[$i]--;
                $vel[$j]++;
            }
        }


        # velocity

        for my $i (0..$n-1) {

            $pos[$i]+=$vel[$i];
        }


        $steps++;
    }
}


sub energy {

    my ($positions,$velocities)=@_;

    my $total=0;


    for my $i (0..$#$positions) {


        my $pot=0;

        my $kin=0;


        for my $x (@{$positions->[$i]}) {

            $pot += abs($x);
        }


        for my $x (@{$velocities->[$i]}) {

            $kin += abs($x);
        }


        $total += $pot*$kin;
    }


    return $total;
}


sub main {


    my $raw=parse();


    my $moons=@$raw;


    my @pos;
    my @vel;


    for my $axis (0..2) {

        $pos[$axis]=[];

        $vel[$axis]=[];

        for my $i (0..$moons-1) {

            push @{$pos[$axis]},
                $raw->[$i][$axis];

            push @{$vel[$axis]},
                0;
        }
    }


    my $pairs =
        combinations($moons);


    # ----------------
    # Part 1
    # ----------------


    for (1..1000) {


        for my $axis (0..2) {


            for my $p (@$pairs) {

                my ($i,$j)=@$p;


                if ($pos[$axis][$i] <
                    $pos[$axis][$j]) {

                    $vel[$axis][$i]++;
                    $vel[$axis][$j]--;

                }
                elsif ($pos[$axis][$i] >
                       $pos[$axis][$j]) {

                    $vel[$axis][$i]--;
                    $vel[$axis][$j]++;
                }
            }
        }


        for my $axis (0..2) {

            for my $i (0..$moons-1) {

                $pos[$axis][$i]+=
                    $vel[$axis][$i];
            }
        }
    }


    my @positions;
    my @velocities;


    for my $i (0..$moons-1) {

        $positions[$i]=[
            $pos[0][$i],
            $pos[1][$i],
            $pos[2][$i]
        ];

        $velocities[$i]=[
            $vel[0][$i],
            $vel[1][$i],
            $vel[2][$i]
        ];
    }


    my $p1 =
        energy(
            \@positions,
            \@velocities
        );


    # ----------------
    # Part 2
    # ----------------


    $raw=parse();


    my @xs;
    my @ys;
    my @zs;


    for my $p (@$raw) {

        push @xs,$p->[0];
        push @ys,$p->[1];
        push @zs,$p->[2];
    }


    my $tx=simulate_axis(\@xs);
    my $ty=simulate_axis(\@ys);
    my $tz=simulate_axis(\@zs);


    my $p2 =
        lcm(
            lcm($tx,$ty),
            $tz
        );


    print "2019 day12: pl_ans_1: $p1\n";
    print "2019 day12: pl_ans_2: $p2\n";
}


main();
