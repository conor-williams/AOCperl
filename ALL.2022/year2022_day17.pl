#!/usr/bin/perl
use strict;
use warnings;


my $file = $ARGV[0];

open(my $fh, "<", $file) or die $!;
my $jets = <$fh>;
chomp($jets);
close($fh);


my @rocks = (

    [
        "####"
    ],

    [
        ".#.",
        "###",
        ".#."
    ],

    [
        "..#",
        "..#",
        "###"
    ],

    [
        "#",
        "#",
        "#",
        "#"
    ],

    [
        "##",
        "##"
    ]
);


my $WIDTH = 7;



sub can_move {

    my ($occupied,$rock,$x,$y)=@_;

    my $h = scalar(@$rock);


    for(my $r=0;$r<$h;$r++) {

        my $row =
            $rock->[$h-1-$r];


        for(my $c=0;$c<length($row);$c++) {

            next if substr($row,$c,1) ne "#";


            my $nx=$x+$c;
            my $ny=$y+$r;


            return 0 if $nx < 0;
            return 0 if $nx >= $WIDTH;
            return 0 if $ny < 0;


            return 0
                if exists $occupied->{"$nx,$ny"};
        }
    }


    return 1;
}



sub place_rock {

    my ($occupied,$rock,$x,$y)=@_;

    my $top=-1;

    my $h=scalar(@$rock);


    for(my $r=0;$r<$h;$r++) {

        my $row =
            $rock->[$h-1-$r];


        for(my $c=0;$c<length($row);$c++) {

            next if substr($row,$c,1) ne "#";


            my $nx=$x+$c;
            my $ny=$y+$r;


            $occupied->{"$nx,$ny"}=1;

            $top=$ny if $ny>$top;
        }
    }


    return $top;
}



sub profile {

    my ($occupied,$highest)=@_;

    my @p;


    for(my $x=0;$x<$WIDTH;$x++) {

        my $y=$highest;


        while($y>=0 &&
              !exists $occupied->{"$x,$y"})
        {
            $y--;
        }


        push @p, $highest-$y;
    }


    return join(",",@p);
}



sub solve {

    my ($jets,$total)=@_;


    my %occupied;

    my $highest=-1;

    my $jet_index=0;

    my $rock_index=0;


    my %seen;

    my $added=0;

    my $used_cycle=0;


    my $jet_len=length($jets);


    while($rock_index < $total) {


        my $rock =
            $rocks[$rock_index % scalar(@rocks)];


        my $x=2;

        my $y=$highest+4;



        while(1) {


            my $push =
                substr($jets,$jet_index % $jet_len,1);

            $jet_index++;


            my $dx =
                ($push eq "<") ? -1 : 1;


            if(can_move(\%occupied,$rock,$x+$dx,$y)) {
                $x += $dx;
            }



            if(can_move(\%occupied,$rock,$x,$y-1)) {

                $y--;

            } else {

                my $top =
                    place_rock(\%occupied,$rock,$x,$y);

                $highest=$top if $top>$highest;

                last;
            }
        }


        $rock_index++;



        unless($used_cycle) {


            my $key =
                ($rock_index % scalar(@rocks)).
                "|".
                ($jet_index % $jet_len).
                "|".
                profile(\%occupied,$highest);



            if(exists $seen{$key}) {


                my ($old_rock,$old_height)=
                    @{$seen{$key}};


                my $cycle_rocks =
                    $rock_index-$old_rock;


                my $cycle_height =
                    $highest-$old_height;


                my $remaining =
                    $total-$rock_index;


                my $cycles =
                    int($remaining/$cycle_rocks);



                if($cycles>0) {

                    $added +=
                        $cycles*$cycle_height;


                    $rock_index +=
                        $cycles*$cycle_rocks;


                    $used_cycle=1;
                }

            } else {

                $seen{$key}=
                    [$rock_index,$highest];
            }
        }
    }


    return $highest+1+$added;
}



my $p1 =
    solve($jets,2022);


my $p2 =
    solve($jets,1000000000000);



print "2022 day17: pl_ans_1: $p1\n";
print "2022 day17: pl_ans_2: $p2\n";
