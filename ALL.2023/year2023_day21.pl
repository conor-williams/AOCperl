#!/usr/bin/perl
use strict;
use warnings;

my $MASK63 = (1 << 63) - 1;


sub parse {

    my($text)=@_;

    my @grid = grep {$_ ne ""} split /\n/,$text;

    my $start;

    for my $r (0..$#grid) {

        my $c=index($grid[$r],"S");

        if($c>=0) {

            $start=[$r,$c];

            substr($grid[$r],$c,1)=".";

            last;
        }
    }

    die "No start\n" unless $start;

    return(\@grid,$start);
}



sub build_wall {

    my($grid)=@_;

    my $R=@$grid;
    my $C=length($grid->[0]);

    my @wall;


    for my $r (0..$R-1) {

        my @w=(0,0,0);


        for my $c (0..$C-1) {

            next if substr($grid->[$r],$c,1) eq "#";


            my $word=int($c/63);
            my $bit=$c%63;

            $w[$word] |= (1 << $bit);
        }


        $w[2] &= 31;

        $wall[$r]=\@w;
    }


    return(\@wall,$R,$C);
}



sub empty_tile {

    my($R)=@_;

    my @t;

    for my $r (0..$R-1) {

        $t[$r]=[0,0,0];
    }

    return \@t;
}



sub set_bit {

    my($tile,$r,$c)=@_;

    my $word=int($c/63);
    my $bit=$c%63;

    $tile->[$r][$word] |= (1 << $bit);
}



sub popcount {

    my($x)=@_;

    my $n=0;

    while($x) {

        $x &= $x-1;

        $n++;
    }

    return $n;
}



sub count_tile {

    my($tile)=@_;

    my $n=0;

    for my $r (@$tile) {

        $n += popcount($r->[0]);
        $n += popcount($r->[1]);
        $n += popcount($r->[2]);
    }

    return $n;
}



sub add_row {

    my($hash,$tr,$tc,$r,$bits)=@_;

    my $key="$tr,$tc";


    unless(exists $hash->{$key}) {

        my @rows;

        for(0..130) {

            $rows[$_]=[0,0,0];
        }

        $hash->{$key}=\@rows;
    }


    $hash->{$key}[$r][0] |= $bits->[0];
    $hash->{$key}[$r][1] |= $bits->[1];
    $hash->{$key}[$r][2] |= $bits->[2];
}



sub step_tiles {

    my($tiles,$wall,$R,$C)=@_;

    my %next;


    for my $key (keys %$tiles) {

        my($tr,$tc)=split /,/,$key;

        my $tile=$tiles->{$key};


        for my $r (0..$R-1) {

            my($w0,$w1,$w2)=@{$tile->[$r]};

            next unless $w0 || $w1 || $w2;



            # WEST
            add_row(
                \%next,
                $tr,
                $tc,
                $r,
                [
    ($w0 >> 1)
    | (($w1 & 1) << 62),

    ($w1 >> 1)
    | (($w2 & 1) << 62),

    ($w2 >> 1)
                ]
            );



            # EAST
            add_row(
                \%next,
                $tr,
                $tc,
                $r,
                [
    ($w0 << 1) & $MASK63,

    (($w1 << 1) & $MASK63)
    | (($w0 >> 62) & 1),

    (($w2 << 1) & 31)
    | (($w1 >> 62) & 1)
                ]
            );

            #
            # tile WEST wrap:
            # column 0 -> column 130
            #
            if($w0 & 1) {

                add_row(
                    \%next,
                    $tr,
                    $tc-1,
                    $r,
                    [0,0,16]
                );
            }



            #
            # tile EAST wrap:
            # column 130 -> column 0
            #
            if($w2 & 16) {

                add_row(
                    \%next,
                    $tr,
                    $tc+1,
                    $r,
                    [1,0,0]
                );
            }




            #
            # NORTH
            #
            if($r==0) {

                add_row(
                    \%next,
                    $tr-1,
                    $tc,
                    $R-1,
                    [$w0,$w1,$w2]
                );

            } else {

                add_row(
                    \%next,
                    $tr,
                    $tc,
                    $r-1,
                    [$w0,$w1,$w2]
                );
            }




            #
            # SOUTH
            #
            if($r==$R-1) {

                add_row(
                    \%next,
                    $tr+1,
                    $tc,
                    0,
                    [$w0,$w1,$w2]
                );

            } else {

                add_row(
                    \%next,
                    $tr,
                    $tc,
                    $r+1,
                    [$w0,$w1,$w2]
                );
            }

        }
    }



    #
    # remove rocks
    #
    for my $key (keys %next) {

        my $tile=$next{$key};


        for my $r (0..$R-1) {

            $tile->[$r][0] &= $wall->[$r][0];
            $tile->[$r][1] &= $wall->[$r][1];
            $tile->[$r][2] &= $wall->[$r][2];
        }


        delete $next{$key}
            if count_tile($tile)==0;
    }


    return \%next;
}





sub reachable_exact {

    my($wall,$R,$C,$start,$steps)=@_;


    my %tiles;


    my $tile=empty_tile($R);


    set_bit(
        $tile,
        $start->[0],
        $start->[1]
    );


    $tiles{"0,0"}=$tile;



    for(1..$steps) {

        my $new=step_tiles(
            \%tiles,
            $wall,
            $R,
            $C
        );

        %tiles=%$new;
    }



    my $ans=0;


    for my $tile (values %tiles) {

        $ans += count_tile($tile);
    }


    return $ans;
}





sub part1 {

    my($wall,$R,$C,$start)=@_;


    return reachable_exact(
        $wall,
        $R,
        $C,
        $start,
        64
    );
}





sub part2 {

    my($wall,$R,$C,$start)=@_;


    my $target=26501365;


    my $base=int($R/2);



    my $y0=reachable_exact(
        $wall,$R,$C,$start,$base
    );


    my $y1=reachable_exact(
        $wall,$R,$C,$start,$base+$R
    );


    my $y2=reachable_exact(
        $wall,$R,$C,$start,$base+2*$R
    );



    my $a=($y2-2*$y1+$y0)/2;

    my $b=$y1-$y0-$a;

    my $c=$y0;


    my $n=int(
        ($target-$base)/$R
    );


    return
        $a*$n*$n
        +$b*$n
        +$c;
}





sub main {


    my $file=$ARGV[0];


    open my $fh,"<",$file
        or die "$file: $!";


    local $/;

    my $text=<$fh>;


    close $fh;



    my($grid,$start)=parse($text);


    my($wall,$R,$C)=build_wall($grid);



    my $ans1=part1(
        $wall,$R,$C,$start
    );


    print "2023 day21: pl_ans_1: $ans1\n";



    my $ans2=part2(
        $wall,$R,$C,$start
    );


    print "2023 day21: pl_ans_2: $ans2\n";
}


main();
