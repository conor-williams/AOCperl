#!/usr/bin/perl
use strict;
use warnings;

my $file = shift @ARGV;

open(my $fh, "<", $file) or die $!;
my @grid0;

while (<$fh>) {
    chomp;
    push @grid0, [ split(//, $_) ];
}

close($fh);

my $H = scalar @grid0;
my $W = scalar @{$grid0[0]};


my @dirs = (
    [1,0],
    [-1,0],
    [0,1],
    [0,-1]
);

my $CY = 2;
my $CX = 2;


# ============================================================
# PART 1
# ============================================================

sub step {

    my ($grid,$H,$W)=@_;

    my @ng;

    for my $y (0..$H-1) {
        $ng[$y]=[];
        for my $x (0..$W-1) {
            $ng[$y][$x]=$grid->[$y][$x];
        }
    }


    for my $y (0..$H-1) {
        for my $x (0..$W-1) {

            my $bugs=0;

            for my $d (@dirs) {

                my $ny=$y+$d->[0];
                my $nx=$x+$d->[1];

                if ($ny>=0 && $ny<$H &&
                    $nx>=0 && $nx<$W) {

                    $bugs++
                        if $grid->[$ny][$nx] eq "#";
                }
            }


            if ($grid->[$y][$x] eq "#") {

                $ng[$y][$x] =
                    ($bugs==1) ? "#" : ".";
            }
            else {

                $ng[$y][$x] =
                    ($bugs==1 || $bugs==2)
                    ? "#"
                    : ".";
            }
        }
    }

    return \@ng;
}



sub biodiversity {

    my ($grid,$H,$W)=@_;

    my $score=0;
    my $i=0;

    for my $y (0..$H-1) {
        for my $x (0..$W-1) {

            if ($grid->[$y][$x] eq "#") {
                $score += 1 << $i;
            }

            $i++;
        }
    }

    return $score;
}



sub solve_part1 {

    my ($grid,$H,$W)=@_;

    my %seen;

    while(1) {

        my $state="";

        for my $row (@$grid) {
            $state .= join("",@$row);
        }


        if (exists $seen{$state}) {
            return biodiversity($grid,$H,$W);
        }

        $seen{$state}=1;

        $grid=step($grid,$H,$W);
    }
}



# ============================================================
# PART 2
# ============================================================


sub empty_level {

    my @g;

    for my $y (0..4) {
        $g[$y]=[];

        for my $x (0..4) {
            $g[$y][$x]=".";
        }
    }

    return \@g;
}



sub count_neighbors {

    my ($levels,$z,$y,$x)=@_;

    my $bugs=0;


    for my $d (@dirs) {

        my $ny=$y+$d->[0];
        my $nx=$x+$d->[1];


        # INTO INNER LEVEL
        if ($ny==$CY && $nx==$CX) {

            my $inner =
                exists $levels->{$z+1}
                ? $levels->{$z+1}
                : empty_level();


            if ($y==$CY-1) {

                for my $i (0..4) {
                    $bugs++ if $inner->[0][$i] eq "#";
                }

            }
            elsif ($y==$CY+1) {

                for my $i (0..4) {
                    $bugs++ if $inner->[4][$i] eq "#";
                }

            }
            elsif ($x==$CX-1) {

                for my $i (0..4) {
                    $bugs++ if $inner->[$i][0] eq "#";
                }

            }
            elsif ($x==$CX+1) {

                for my $i (0..4) {
                    $bugs++ if $inner->[$i][4] eq "#";
                }
            }
        }


        # OUTER LEVEL

        elsif ($ny < 0) {

            my $outer =
                exists $levels->{$z-1}
                ? $levels->{$z-1}
                : empty_level();

            $bugs++ if $outer->[1][2] eq "#";
        }


        elsif ($ny >= 5) {

            my $outer =
                exists $levels->{$z-1}
                ? $levels->{$z-1}
                : empty_level();

            $bugs++ if $outer->[3][2] eq "#";
        }


        elsif ($nx < 0) {

            my $outer =
                exists $levels->{$z-1}
                ? $levels->{$z-1}
                : empty_level();

            $bugs++ if $outer->[2][1] eq "#";
        }


        elsif ($nx >= 5) {

            my $outer =
                exists $levels->{$z-1}
                ? $levels->{$z-1}
                : empty_level();

            $bugs++ if $outer->[2][3] eq "#";
        }


        else {

            $bugs++
                if exists $levels->{$z} &&
                   $levels->{$z}->[$ny][$nx] eq "#";
        }
    }


    return $bugs;
}




sub step_recursive {

    my ($levels)=@_;

    my %new;


    my @keys=keys %$levels;

    my $min=$keys[0];
    my $max=$keys[0];

    for my $k (@keys) {
        $min=$k if $k<$min;
        $max=$k if $k>$max;
    }


    for my $z ($min-1 .. $max+1) {

        my $g=empty_level();


        for my $y (0..4) {
            for my $x (0..4) {


                next if $y==$CY && $x==$CX;


                my $bugs=count_neighbors(
                    $levels,$z,$y,$x
                );


                my $cur=".";

                if (exists $levels->{$z}) {
                    $cur=$levels->{$z}->[$y][$x];
                }


                if ($cur eq "#") {

                    $g->[$y][$x] =
                        ($bugs==1) ? "#" : ".";
                }
                else {

                    $g->[$y][$x] =
                        ($bugs==1 || $bugs==2)
                        ? "#"
                        : ".";
                }
            }
        }


        $new{$z}=$g;
    }


    return \%new;
}



sub solve_part2 {

    my ($grid)=@_;

    my %levels;

    $levels{0}=$grid;


    for (1..200) {
        %levels=%{step_recursive(\%levels)};
    }


    my $total=0;


    for my $z (keys %levels) {

        for my $y (0..4) {
            for my $x (0..4) {

                next if $y==$CY && $x==$CX;

                $total++
                    if $levels{$z}->[$y][$x] eq "#";
            }
        }
    }

    return $total;
}



# ============================================================
# MAIN
# ============================================================

my $p1=solve_part1(\@grid0,$H,$W);

print "2019 day24: pl_ans_1: $p1\n";


my $p2=solve_part2(\@grid0);

print "2019 day24: pl_ans_2: $p2\n";
