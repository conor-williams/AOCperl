#!/usr/bin/perl
use strict;
use warnings;

use List::Util qw(min max);


# ============================================================
# Heap (Python heapq equivalent)
# ============================================================

sub heappush {
    my ($h,$item)=@_;

    push @$h,$item;

    my $i=$#$h;

    while($i>0){

        my $p=int(($i-1)/2);

        last if $h->[$p][0] <= $h->[$i][0];

        ($h->[$p],$h->[$i]) =
        ($h->[$i],$h->[$p]);

        $i=$p;
    }
}


sub heappop {

    my ($h)=@_;

    my $ret=$h->[0];

    my $last=pop @$h;

    if(@$h){

        $h->[0]=$last;

        my $i=0;

        while(1){

            my $l=$i*2+1;
            my $r=$i*2+2;

            my $small=$i;


            if($l<@$h &&
               $h->[$l][0]<$h->[$small][0]){
                $small=$l;
            }

            if($r<@$h &&
               $h->[$r][0]<$h->[$small][0]){
                $small=$r;
            }

            last if $small==$i;

            ($h->[$i],$h->[$small]) =
            ($h->[$small],$h->[$i]);

            $i=$small;
        }
    }

    return $ret;
}



# ============================================================
# Input
# ============================================================

my $file=shift @ARGV;

open my $fh,"<",$file or die $!;

my @original;

while(<$fh>){

    chomp;

    push @original,[split //];

}

close $fh;



my @DY=(-1,0,1,0);
my @DX=(0,1,0,-1);



# ============================================================
# Solver
# ============================================================

sub solve {

    my ($grid)=@_;

    my $H=@$grid;
    my $W=@{$grid->[0]};


    # --------------------------------------------------------
    # Find keys and robots
    # --------------------------------------------------------

    my %locations;

    my $robot=0;

    for my $y(0..$H-1){

        for my $x(0..$W-1){

            my $c=$grid->[$y][$x];

            if($c =~ /[a-z]/){

                $locations{$c}=[$y,$x];

            }
            elsif($c eq '@'){

                $locations{$robot}=
                    [$y,$x];

                $robot++;

            }
        }
    }


    my $num_keys =
        scalar grep {/[a-z]/} keys %locations;



    # --------------------------------------------------------
    # BFS from one location
    # --------------------------------------------------------

    sub bfs {

        my ($grid,$start)=@_;

        my $H=@$grid;
        my $W=@{$grid->[0]};


        my @q=(
            [
                $start->[0],
                $start->[1],
                0,
                {}
            ]
        );


        my %seen;
        my %found;


        while(@q){

            my $cur=shift @q;

            my ($y,$x,$dist,$req)=@$cur;


            next if $seen{"$y,$x"};

            $seen{"$y,$x"}=1;


            my $cell=$grid->[$y][$x];


            if($cell =~ /[a-z]/ &&
               !($y==$start->[0] &&
                 $x==$start->[1])){

                $found{$cell}=[$dist,$req];
            }



            for my $d(0..3){

                my $ny=$y+$DY[$d];
                my $nx=$x+$DX[$d];


                next if $ny<0 ||
                        $nx<0 ||
                        $ny>=$H ||
                        $nx>=$W;


                my $next=$grid->[$ny][$nx];

                next if $next eq '#';


                my %new=%$req;


                if($next =~ /[A-Z]/){

                    $new{lc($next)}=1;
                }


                push @q,
                [
                    $ny,
                    $nx,
                    $dist+1,
                    \%new
                ];
            }
        }


        return \%found;
    }



    # --------------------------------------------------------
    # Build graph
    # --------------------------------------------------------

    my %graph;

    for my $k(keys %locations){

        $graph{$k}=bfs(
            $grid,
            $locations{$k}
        );
    }



    # robots

    my @starts =
        sort grep {$_ =~ /^\d+$/}
        keys %locations;



    # --------------------------------------------------------
    # Dijkstra
    # --------------------------------------------------------

    my @heap;

    heappush(
        \@heap,
        [
            0,
            \@starts,
            {}
        ]
    );


    my %best;


    while(@heap){

        my $node=heappop(\@heap);

        my ($dist,$robots,$keys)=@$node;


        my $keystr=
            join(",",
                @$robots,
                sort keys %$keys
            );


        next if exists $best{$keystr};

        $best{$keystr}=$dist;


        return $dist
            if scalar(keys %$keys)==$num_keys;



        for my $i(0..$#$robots){

            my $pos=$robots->[$i];


            for my $next(keys %{$graph{$pos}}){

                next if exists $keys->{$next};


                my ($cost,$need)=
                    @{$graph{$pos}{$next}};


                my $ok=1;

                for my $k(keys %$need){

                    if(!exists $keys->{$k}){
                        $ok=0;
                    }
                }

                next unless $ok;


                my @newrobots=@$robots;

                $newrobots[$i]=$next;


                my %newkeys=%$keys;

                $newkeys{$next}=1;


                heappush(
                    \@heap,
                    [
                        $dist+$cost,
                        \@newrobots,
                        \%newkeys
                    ]
                );
            }
        }
    }


    return undef;
}



# ============================================================
# Part 1
# ============================================================

my $p1=solve(\@original);

print "2019 day18: pl_ans_1: $p1\n";



# ============================================================
# Part 2 modify map
# ============================================================

my @grid2 =
    map {[ @$_ ]}
    @original;


my ($ay,$ax);

FOUND:
for my $y(0..$#grid2){

    for my $x(0..$#{$grid2[$y]}){

        if($grid2[$y][$x] eq '@'){

            $ay=$y;
            $ax=$x;

            last FOUND;
        }
    }
}



$grid2[$ay][$ax]='#';

$grid2[$ay-1][$ax]='#';
$grid2[$ay+1][$ax]='#';
$grid2[$ay][$ax-1]='#';
$grid2[$ay][$ax+1]='#';


$grid2[$ay-1][$ax-1]='@';
$grid2[$ay-1][$ax+1]='@';
$grid2[$ay+1][$ax-1]='@';
$grid2[$ay+1][$ax+1]='@';



my $p2=solve(\@grid2);


print "2019 day18: pl_ans_2: $p2\n";
