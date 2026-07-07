#!/usr/bin/perl
use strict;
use warnings;

my $file = $ARGV[0] or die "input file required\n";

open my $fh, "<", $file or die $!;
my @grid;

while (<$fh>) {
    chomp;
    push @grid, [split //];
}
close $fh;

my $H = scalar @grid;
my $W = scalar @{$grid[0]};

my @base_units;
my @base_map;

for my $y (0..$H-1) {
    my @row;

    for my $x (0..$W-1) {

        my $c = $grid[$y][$x];

        if ($c eq '#') {
            push @row, -1;
        }
        elsif ($c eq '.') {
            push @row, -2;
        }
        else {
            my $id = scalar @base_units;

            push @base_units,
                [200,$y,$x,$c];

            push @row,$id;
        }
    }

    push @base_map,\@row;
}


my $elves = scalar grep {
    $_->[3] eq 'E'
} @base_units;



sub copy_state {

    my @units;

    for my $u (@base_units) {
        push @units, [@$u];
    }


    my @map;

    for my $r (@base_map) {
        push @map, [@$r];
    }

    return (\@map,\@units);
}



sub neighbours {

    my ($pos)=@_;

    my $y = int($pos / $W);
    my $x = $pos % $W;

    my @n;

    push @n, ($y-1)*$W+$x if $y>0;
    push @n, $y*$W+$x-1 if $x>0;
    push @n, $y*$W+$x+1 if $x<$W-1;
    push @n, ($y+1)*$W+$x if $y<$H-1;

    return @n;
}



my @near;

for my $y (0..$H-1) {
    for my $x (0..$W-1) {
        $near[$y*$W+$x] =
            [ neighbours($y*$W+$x) ];
    }
}


sub find_move {

    my ($map,$units,$uid)=@_;

    my $u=$units->[$uid];

    my $start =
        $u->[1]*$W+$u->[2];


    my @queue=($start);
    my $head=0;

    my @seen;
    my @parent;

    $seen[$start]=1;


    while ($head < @queue) {

        my $pos=$queue[$head++];


        for my $n (@{$near[$pos]}) {

            my $cell =
                $map->[int($n/$W)][$n%$W];


            # enemy found
            if ($cell >= 0) {

                next
                    if $units->[$cell][3] eq $u->[3];


                # walk back to first step
                my $step=$pos;

                while (defined $parent[$step]
                       && $parent[$step] != $start) {

                    $step=$parent[$step];
                }


                return [
                    int($step/$W),
                    $step%$W
                ];
            }


            next unless $cell == -2;

            next if defined $seen[$n];

            $seen[$n]=1;
            $parent[$n]=$pos;

            push @queue,$n;
        }
    }

    return undef;
}


sub find_attack {

    my ($map,$units,$uid)=@_;

    my $u=$units->[$uid];

    my $best;


    my $pos=$u->[1]*$W+$u->[2];


    for my $n (@{$near[$pos]}) {

        my $cell =
            $map->[int($n/$W)][$n%$W];


        next if $cell < 0;

        next
            if $units->[$cell][3] eq $u->[3];


        if (!defined $best ||
            $units->[$cell][0] <
            $units->[$best][0]) {

            $best=$cell;
        }
    }

    return $best;
}



sub battle {

    my ($map,$units,$elf_power)=@_;

    my ($e,$g)=(0,0);

    for my $u (@$units) {
        $u->[3] eq 'E' ? $e++ : $g++;
    }


    for my $round (0..9999) {


        my @order =
            sort {
                $units->[$a][1] <=> $units->[$b][1]
                ||
                $units->[$a][2] <=> $units->[$b][2]
            }
            grep {
                $units->[$_][0] > 0
            }
            (0..$#$units);



        for my $uid (@order) {

            my $u=$units->[$uid];

            next if $u->[0] <= 0;


            return [$e,$g,$round]
                if !$e || !$g;


            my $move =
                find_move($map,$units,$uid);


            if ($move) {

                $map->[$u->[1]][$u->[2]]=-2;

                ($u->[1],$u->[2])=@$move;

                $map->[$u->[1]][$u->[2]]=$uid;
            }


            my $enemy =
                find_attack($map,$units,$uid);


            if (defined $enemy) {

                if ($u->[3] eq 'E') {
                    $units->[$enemy][0]-=$elf_power;
                }
                else {
                    $units->[$enemy][0]-=3;
                }


                if ($units->[$enemy][0] <= 0) {

                    $map->[
                        $units->[$enemy][1]
                    ][
                        $units->[$enemy][2]
                    ]=-2;


                    if ($units->[$enemy][3] eq 'E') {
                        $e--;
                    }
                    else {
                        $g--;
                    }
                }
            }
        }
    }
}



for (my $power=3;;$power++) {

    my ($map,$units)=copy_state();

    my $result =
        battle($map,$units,$power);


    if ($power==3) {

        my $sum=0;

        $sum += $_->[0]
            for grep {
                $_->[0]>0
            } @$units;

        print "2018 day15: pl_ans_1: ",
              $result->[2]*$sum,
              "\n";
    }


    if ($result->[0] == $elves) {

        my $sum=0;

        $sum += $_->[0]
            for grep {
                $_->[0]>0
            } @$units;

        print "2018 day15: pl_ans_2: ",
              $result->[2]*$sum,
              "\n";

        last;
    }
}
