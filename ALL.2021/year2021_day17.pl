use strict;
use warnings;


my $file=$ARGV[0];

open my $fh,"<",$file or die "$!\n";

my $line=<$fh>;

close $fh;


$line =~ /x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)/;

my ($xmin,$xmax,$ymin,$ymax)=($1,$2,$3,$4);



sub test_shot {

    my ($vx,$vy,$xmin,$xmax,$ymin,$ymax)=@_;


    my ($x,$y)=(0,0);

    my $max_y=0;


    while (1) {


        $x += $vx;
        $y += $vy;


        $vx-- if $vx>0;
        $vx++ if $vx<0;

        $vy--;


        $max_y=$y if $y>$max_y;



        if ($x >= $xmin &&
            $x <= $xmax &&
            $y >= $ymin &&
            $y <= $ymax) {

            return $max_y;
        }



        if ($y < $ymin || $x > $xmax+2) {

            return -1;
        }
    }
}



my $best=0;
my $count=0;


for my $vx (1..$xmax) {

    for my $vy ($ymin .. -$ymin+1) {


        my $h=test_shot(
            $vx,$vy,
            $xmin,$xmax,
            $ymin,$ymax
        );


        if ($h>=0) {

            $count++;

            $best=$h if $h>$best;
        }
    }
}



print "2021 day17: pl_ans_1: $best\n";
print "2021 day17: pl_ans_2: $count\n";
