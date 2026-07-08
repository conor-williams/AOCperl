use strict;
use warnings;


my $file=$ARGV[0];

open my $fh,"<",$file or die "$!\n";

my @lines=grep { /\S/ } <$fh>;

close $fh;


my $p1_start=(split /:/,$lines[0])[1];
my $p2_start=(split /:/,$lines[1])[1];

$p1_start =~ s/\s+//g;
$p2_start =~ s/\s+//g;



# -------------------------
# Part 1
# -------------------------

sub solve_part1 {

    my ($p1,$p2)=@_;

    my ($s1,$s2)=(0,0);

    my $die=1;
    my $rolls=0;


    while (1) {


        my $move=0;

        for (1..3) {

            $move += $die;

            $die++;

            $die=1 if $die>100;

            $rolls++;
        }


        $p1=(($p1+$move-1)%10)+1;

        $s1 += $p1;


        return $s2*$rolls if $s1>=1000;



        $move=0;

        for (1..3) {

            $move += $die;

            $die++;

            $die=1 if $die>100;

            $rolls++;
        }


        $p2=(($p2+$move-1)%10)+1;

        $s2 += $p2;


        return $s1*$rolls if $s2>=1000;
    }
}



# -------------------------
# Part 2
# -------------------------

my @rolls = (
    [3,1],
    [4,3],
    [5,6],
    [6,7],
    [7,6],
    [8,3],
    [9,1],
);



my %memo;


sub play {

    my ($p1,$p2,$s1,$s2,$turn)=@_;


    my $key =
        join ",",
        $p1,$p2,$s1,$s2,$turn;


    return @{$memo{$key}}
        if exists $memo{$key};



    return (1,0) if $s1>=21;

    return (0,1) if $s2>=21;



    my ($w1,$w2)=(0,0);



    for my $r (@rolls) {

        my ($move,$count)=@$r;


        my ($a,$b);


        if ($turn==0) {

            my $np1=(($p1+$move-1)%10)+1;

            ($a,$b)=
                play(
                    $np1,
                    $p2,
                    $s1+$np1,
                    $s2,
                    1
                );

        }
        else {

            my $np2=(($p2+$move-1)%10)+1;

            ($a,$b)=
                play(
                    $p1,
                    $np2,
                    $s1,
                    $s2+$np2,
                    0
                );
        }


        $w1 += $a*$count;
        $w2 += $b*$count;
    }


    $memo{$key}=[$w1,$w2];

    return ($w1,$w2);
}



my $ans1=solve_part1($p1_start,$p2_start);


my ($w1,$w2)=play(
    $p1_start,
    $p2_start,
    0,
    0,
    0
);


my $ans2=$w1>$w2 ? $w1:$w2;



print "2021 day21: pl_ans_1: $ans1\n";
print "2021 day21: pl_ans_2: $ans2\n";
