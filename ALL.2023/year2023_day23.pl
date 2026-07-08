#!/usr/bin/perl
use strict;
use warnings;

my $file=$ARGV[0];

open(my $fh,"<",$file) or die;
my @grid=grep { chomp; $_ ne "" } <$fh>;
close($fh);


my $R=@grid;
my $C=length($grid[0]);


my @dirs=(
    [0,1],
    [1,0],
    [0,-1],
    [-1,0]
);



sub inside {

    my($r,$c)=@_;

    return $r>=0 && $r<$R && $c>=0 && $c<$C;
}



sub build_graph {


    my %isnode;


    my $start="0,".index($grid[0],".");

    my $end=($R-1).",".index($grid[-1],".");


    $isnode{$start}=1;
    $isnode{$end}=1;



    for my $r (0..$R-1) {

        for my $c (0..$C-1) {


            next if substr($grid[$r],$c,1) eq "#";


            my $cnt=0;


            for my $d (@dirs) {

                my($nr,$nc)=(
                    $r+$d->[0],
                    $c+$d->[1]
                );


                next unless inside($nr,$nc);


                $cnt++ if substr($grid[$nr],$nc,1) ne "#";
            }


            $isnode{"$r,$c"}=1 if $cnt>2;
        }
    }



    my @nodes=keys %isnode;


    my %id;


    for my $i (0..$#nodes) {

        $id{$nodes[$i]}=$i;
    }



    my @adj;



    for my $name (@nodes) {


        my $from=$id{$name};


        my($r,$c)=split/,/,$name;


        my @stack=([$r,$c,0]);


        my %seen=($name=>1);



        while(@stack) {


            my($cr,$cc,$dist)=@{pop @stack};


            my $key="$cr,$cc";



            if($dist && exists $isnode{$key}) {


                push @{$adj[$from]},
                    [$id{$key},$dist];


                next;
            }



            for my $d (@dirs) {


                my($nr,$nc)=(
                    $cr+$d->[0],
                    $cc+$d->[1]
                );


                next unless inside($nr,$nc);


                next if substr($grid[$nr],$nc,1) eq "#";


                my $nk="$nr,$nc";


                next if $seen{$nk};


                $seen{$nk}=1;


                push @stack,
                    [$nr,$nc,$dist+1];
            }
        }
    }



    for my $a (@adj) {

        @$a=sort {$b->[1] <=> $a->[1]} @$a if $a;
    }



    return(
        \@adj,
        $id{$start},
        $id{$end}
    );
}



my($adj,$START,$END)=build_graph();


my @adj=@$adj;


my $N=@adj;


my @BIT=map {1<<$_} 0..$N-1;



#
# Maximum possible outgoing contribution
#

my @node_max;


for my $n (0..$N-1) {


    my $m=0;


    for my $e (@{$adj[$n]}) {

        $m=$e->[1] if $e->[1]>$m;
    }


    $node_max[$n]=$m;
}



my $all_max=0;


$all_max += $_ for @node_max;



#print "nodes=$N\n";

#
# PART 1
#

sub part1 {

    my $sr=0;
    my $sc=index($grid[0],".");

    my $er=$R-1;
    my $ec=index($grid[-1],".");


    my @seen=map { [(0)x$C] } 0..$R-1;


    my $best=0;


    my @dr=(0,1,0,-1);
    my @dc=(1,0,-1,0);


    no warnings 'recursion';


    my $dfs1;


    $dfs1=sub {

        my($r,$c,$dist)=@_;


        if($r==$er && $c==$ec) {

            $best=$dist if $dist>$best;

            return;
        }


        $seen[$r][$c]=1;


        for my $d (0..3) {


            my $nr=$r+$dr[$d];
            my $nc=$c+$dc[$d];


            next unless inside($nr,$nc);

            next if $seen[$nr][$nc];


            my $ch=substr($grid[$nr],$nc,1);


            next if $ch eq "#";


            next if $ch eq ">" && $d!=0;
            next if $ch eq "v" && $d!=1;
            next if $ch eq "<" && $d!=2;
            next if $ch eq "^" && $d!=3;


            $dfs1->($nr,$nc,$dist+1);
        }


        $seen[$r][$c]=0;
    };


    $dfs1->($sr,$sc,0);


    return $best;
}



#
# PART 2
#

my @best_state = map { {} } 0..$N-1;


my $BEST=0;

my $calls=0;



#
# Incremental safe bound:
#
# Maintain sum of maximum possible unused-node exits.
#

sub dfs {


    my($node,$mask,$dist,$remain)=@_;


    $calls++;


    #
    # Safe pruning
    #
    return if $dist+$remain <= $BEST;



    if($node==$END) {


        $BEST=$dist if $dist>$BEST;


        return;
    }



    my $seen=$best_state[$node];



    if(exists $seen->{$mask}) {


        return if $seen->{$mask}>=$dist;

    }


    $seen->{$mask}=$dist;



    for my $e (@{$adj[$node]}) {


        my($next,$w)=@$e;


        my $bit=$BIT[$next];


        next if $mask & $bit;



        dfs(
            $next,
            $mask|$bit,
            $dist+$w,
            $remain-$node_max[$next]
        );
    }
}



#
# Start with all node potential available
#

dfs(
    $START,
    $BIT[$START],
    0,
    $all_max
);



my $p1=part1();



my $states=0;

$states += scalar(keys %$_) for @best_state;



#print "calls=$calls\n";
#print "states=$states\n";


print "2023 day23: pl_ans_1: $p1\n";
print "2023 day23: pl_ans_2: $BEST\n";
