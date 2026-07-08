#!/usr/bin/perl
use strict;
use warnings;


my $file=$ARGV[0];

open(my $fh,"<",$file) or die "Cannot open $file\n";


my %graph;


while(<$fh>) {

    chomp;

    next if $_ eq "";

    my ($left,$right)=split /:/;

    my $u=$left;

    for my $v (split /\s+/,$right) {

        next if $v eq "";

        $graph{$u}{$v}=1;
        $graph{$v}{$u}=1;
    }
}


close($fh);



sub bfs {

    my ($start,$target,$graph)=@_;

    my @queue=($start);

    my %prev;

    $prev{$start}=undef;


    while(@queue) {

        my $u=shift @queue;

        last if $u eq $target;


        for my $v (keys %{$graph->{$u}}) {

            next if exists $prev{$v};

            $prev{$v}=$u;

            push @queue,$v;
        }
    }


    return () unless exists $prev{$target};


    my @path;

    my $cur=$target;


    while(defined $prev{$cur}) {

        push @path, [$prev{$cur},$cur];

        $cur=$prev{$cur};
    }


    return @path;
}



sub find_cut_edges {

    my ($graph)=@_;

    my %edge_count;


    my @nodes=keys %$graph;


    for my $i (0..1999) {

        my $a=$nodes[$i % @nodes];
        my $b=$nodes[($i*7) % @nodes];


        next if $a eq $b;


        my @path=bfs($a,$b,$graph);


        for my $e (@path) {

            my ($x,$y)=@$e;


            my $key;

            if ($x lt $y) {
                $key="$x,$y";
            }
            else {
                $key="$y,$x";
            }


            $edge_count{$key}++;
        }
    }



    my @sorted =
        sort {
            $edge_count{$b} <=> $edge_count{$a}
        }
        keys %edge_count;


    my @cut=@sorted[0..2];


    my @result;


    for my $e (@cut) {

        my ($a,$b)=split /,/,$e;

        push @result,[$a,$b];
    }


    return @result;
}



sub remove_edges {

    my ($graph,@edges)=@_;


    my %g;


    for my $k (keys %$graph) {

        $g{$k}={};

        for my $v (keys %{$graph->{$k}}) {

            $g{$k}{$v}=1;
        }
    }


    for my $e (@edges) {

        my ($a,$b)=@$e;

        delete $g{$a}{$b};
        delete $g{$b}{$a};
    }


    return %g;
}



sub component_size {

    my ($graph,$start)=@_;


    my %seen;

    my @queue=($start);


    while(@queue) {

        my $u=shift @queue;

        next if $seen{$u};

        $seen{$u}=1;


        for my $v (keys %{$graph->{$u}}) {

            next if $seen{$v};

            push @queue,$v;
        }
    }


    return scalar keys %seen;
}



my @cut=find_cut_edges(\%graph);


my %graph2=remove_edges(\%graph,@cut);


my ($start)=keys %graph2;


my $size=component_size(\%graph2,$start);


my $total=scalar keys %graph2;


print "2023 day25: pl_ans_1: ", $size*($total-$size), "\n";
