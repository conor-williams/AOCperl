use strict;
use warnings;


my $file=$ARGV[0];

open my $fh,"<",$file or die "$!\n";

my @lines=grep { /\S/ } map { chomp; $_ } <$fh>;

close $fh;



sub parse_num {

    my ($s)=@_;

    my @out;
    my $depth=0;
    my $num="";


    for my $c (split //,$s) {

        if ($c eq "[") {

            $depth++;

        }
        elsif ($c eq "]") {

            if ($num ne "") {
                push @out, [$num+0,$depth];
                $num="";
            }

            $depth--;

        }
        elsif ($c eq ",") {

            if ($num ne "") {
                push @out, [$num+0,$depth];
                $num="";
            }

        }
        else {

            $num .= $c;
        }
    }


    if ($num ne "") {
        push @out, [$num+0,$depth];
    }


    return \@out;
}



sub add {

    my ($a,$b)=@_;

    my @out;


    for (@$a,@$b) {

        push @out,[$_->[0],$_->[1]+1];
    }

    return \@out;
}



sub explode {

    my ($n)=@_;


    for my $i (0..$#$n-1) {

        if ($n->[$i][1] > 4 &&
            $n->[$i][1] == $n->[$i+1][1]) {


            $n->[$i-1][0] += $n->[$i][0]
                if $i>0;


            $n->[$i+2][0] += $n->[$i+1][0]
                if $i+2 <= $#$n;


            splice @$n,$i,2,
                [0,$n->[$i][1]-1];


            return 1;
        }
    }


    return 0;
}



sub split_num {

    my ($n)=@_;


    for my $i (0..$#$n) {

        if ($n->[$i][0] >= 10) {

            my $v=$n->[$i][0];
            my $d=$n->[$i][1];


            splice @$n,$i,1,
                [
                    int($v/2),
                    $d+1
                ],
                [
                    int(($v+1)/2),
                    $d+1
                ];

            return 1;
        }
    }

    return 0;
}



sub reduce_num {

    my ($n)=@_;

    while (1) {

        next if explode($n);

        next if split_num($n);

        last;
    }

    return $n;
}



sub magnitude {

    my ($n)=@_;

    my @x=map { [@$_] } @$n;


    while (@x>1) {

        for my $i (0..$#x-1) {

            if ($x[$i][1] == $x[$i+1][1]) {

                my $v =
                    3*$x[$i][0]
                    +
                    2*$x[$i+1][0];


                splice @x,$i,2,
                    [$v,$x[$i][1]-1];

                last;
            }
        }
    }


    return $x[0][0];
}



my @nums=map { parse_num($_) } @lines;


my $cur=$nums[0];

for my $i (1..$#nums) {

    $cur=reduce_num(add($cur,$nums[$i]));
}


my $p1=magnitude($cur);



my $p2=0;


for my $i (0..$#nums) {

    for my $j (0..$#nums) {

        next if $i==$j;

        my $m=magnitude(
            reduce_num(
                add($nums[$i],$nums[$j])
            )
        );

        $p2=$m if $m>$p2;
    }
}



print "2021 day18: pl_ans_1: $p1\n";
print "2021 day18: pl_ans_2: $p2\n";
