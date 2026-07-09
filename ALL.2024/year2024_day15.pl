#!/usr/bin/env perl

use strict;
use warnings;


my $path = $ARGV[0];

open my $fh, '<', $path or die "$path: $!";

local $/;
my $input = <$fh>;

close $fh;


my ($map, $moves) = split /\n\n/, $input;

$moves =~ s/\n//g;



my %dirs = (
    "^" => [0,-1],
    "v" => [0,1],
    "<" => [-1,0],
    ">" => [1,0],
);



# ============================================================
# PART 1
# ============================================================

sub part1 {

    my ($map,$moves,$dirs)=@_;


    my @grid =
        map { [split //] }
        split /\n/, $map;


    my $h=@grid;
    my $w=@{$grid[0]};


    my ($sx,$sy);


    for my $y (0..$h-1) {
        for my $x (0..$w-1) {

            if ($grid[$y][$x] eq "@") {

                ($sx,$sy)=($x,$y);
                $grid[$y][$x]=".";
            }
        }
    }


    for my $move (split //,$moves) {

        my ($dx,$dy)=@{$dirs->{$move}};


        my $nx=$sx+$dx;
        my $ny=$sy+$dy;


        if ($grid[$ny][$nx] eq ".") {

            ($sx,$sy)=($nx,$ny);

        }
        elsif ($grid[$ny][$nx] eq "O") {


            my ($bx,$by)=($nx,$ny);


            while ($grid[$by][$bx] eq "O") {

                $bx += $dx;
                $by += $dy;
            }


            if ($grid[$by][$bx] eq ".") {

                $grid[$by][$bx]="O";
                $grid[$ny][$nx]=".";

                ($sx,$sy)=($nx,$ny);
            }
        }
    }


    my $answer=0;


    for my $y (0..$h-1) {
        for my $x (0..$w-1) {

            if ($grid[$y][$x] eq "O") {
                $answer += 100*$y+$x;
            }
        }
    }


    return $answer;
}





# ============================================================
# PART 2
# ============================================================


sub can_push {

    my ($grid,$boxes,$dy)=@_;


    my %next;


    for my $box (@$boxes) {

        my ($x,$y)=@$box;


        for my $xx ($x,$x+1) {


            my $ny=$y+$dy;


            my $c=$grid->[$ny]->[$xx];


            return undef if $c eq "#";


            if ($c eq "[") {

                $next{"$xx,$ny"}=[$xx,$ny];

            }
            elsif ($c eq "]") {

                $next{($xx-1).",$ny"}=[$xx-1,$ny];

            }
        }
    }


    return $boxes unless %next;


    my $pushed =
        can_push($grid,[values %next],$dy);


    return undef unless $pushed;


    return [@$boxes,@$pushed];
}



sub part2 {

    my ($map,$moves,$dirs)=@_;


    my %expand = (
        "#" => "##",
        "." => "..",
        "O" => "[]",
        "@" => "@.",
    );


    my @grid;


    for my $row (split /\n/,$map) {

        my $line="";


        for my $c (split //,$row) {

            $line .= $expand{$c};
        }


        push @grid,[split //,$line];
    }



    my $h=@grid;
    my $w=@{$grid[0]};


    my ($sx,$sy);


    for my $y (0..$h-1) {
        for my $x (0..$w-1) {

            if ($grid[$y][$x] eq "@") {

                ($sx,$sy)=($x,$y);
                $grid[$y][$x]=".";
            }
        }
    }



    for my $move (split //,$moves) {


        my ($dx,$dy)=@{$dirs->{$move}};


        my $nx=$sx+$dx;
        my $ny=$sy+$dy;


        my $c=$grid[$ny][$nx];



        if ($c eq ".") {

            ($sx,$sy)=($nx,$ny);

        }
        elsif ($c eq "#") {

            next;

        }
        elsif ($move eq "<" || $move eq ">") {


            my $tx=$nx;


            while ($grid[$sy][$tx] eq "[" ||
                   $grid[$sy][$tx] eq "]") {

                $tx += $dx;
            }


            if ($grid[$sy][$tx] eq ".") {


                while ($tx != $sx) {

                    $grid[$sy][$tx] =
                        $grid[$sy][$tx-$dx];

                    $tx -= $dx;
                }


                $grid[$sy][$sx]=".";

                $sx += $dx;
            }


        }
        else {


            my $start;


            if ($c eq "[") {

                $start=[$nx,$ny];

            }
            else {

                $start=[$nx-1,$ny];
            }



            my $boxes =
                can_push(\@grid,[$start],$dy);



            if ($boxes) {


                my @order;


                if ($dy > 0) {

                    @order =
                        sort { $b->[1] <=> $a->[1] }
                        @$boxes;

                }
                else {

                    @order =
                        sort { $a->[1] <=> $b->[1] }
                        @$boxes;
                }



                for my $box (@order) {

                    my ($x,$y)=@$box;

                    $grid[$y][$x]=".";
                    $grid[$y][$x+1]=".";
                }



                for my $box (@order) {

                    my ($x,$y)=@$box;

                    $grid[$y+$dy][$x]="[";
                    $grid[$y+$dy][$x+1]="]";
                }


                ($sx,$sy)=($nx,$ny);
            }
        }
    }



    my $answer=0;


    for my $y (0..$h-1) {
        for my $x (0..$w-1) {

            if ($grid[$y][$x] eq "[") {

                $answer += 100*$y+$x;
            }
        }
    }


    return $answer;
}



my $p1=part1($map,$moves,\%dirs);
my $p2=part2($map,$moves,\%dirs);


print "2024 day15: pl_ans_1: $p1\n";
print "2024 day15: pl_ans_2: $p2\n";
