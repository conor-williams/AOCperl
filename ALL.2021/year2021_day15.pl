use strict;
use warnings;


my $file = $ARGV[0];

open my $fh, "<", $file or die "$!\n";


my @grid;

while (<$fh>) {

    chomp;

    next unless /\S/;

    push @grid, [ map { int($_) } split // ];
}

close $fh;


my $R = scalar @grid;
my $C = scalar @{$grid[0]};



sub solve {

    my ($scale)=@_;


    my $R2 = $R * $scale;
    my $C2 = $C * $scale;


    my @dist;

    for my $r (0..$R2-1) {

        $dist[$r] = [];

        for my $c (0..$C2-1) {

            $dist[$r][$c] = 10**18;
        }
    }


    $dist[0][0]=0;


    # priority queue replacement using sorted array
    my @queue = ([0,0,0]);


    while (@queue) {


        @queue = sort { $a->[0] <=> $b->[0] } @queue;


        my $cur = shift @queue;


        my ($d,$r,$c)=@$cur;


        next if $d != $dist[$r][$c];


        return $d if $r == $R2-1 && $c == $C2-1;



        my @dirs = (
            [1,0],
            [-1,0],
            [0,1],
            [0,-1]
        );


        for my $dir (@dirs) {

            my $nr=$r+$dir->[0];
            my $nc=$c+$dir->[1];


            next if $nr<0 || $nr >= $R2;
            next if $nc<0 || $nc >= $C2;



            my $risk =
                $grid[$nr % $R][$nc % $C]
                + int($nr/$R)
                + int($nc/$C);


            $risk = (($risk-1) % 9)+1;


            my $nd=$d+$risk;


            if ($nd < $dist[$nr][$nc]) {

                $dist[$nr][$nc]=$nd;

                push @queue, [$nd,$nr,$nc];
            }
        }
    }
}



print "2021 day15: pl_ans_1: ", solve(1), "\n";
print "2021 day15: pl_ans_2: ", solve(5), "\n";
