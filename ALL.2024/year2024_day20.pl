use strict;
use warnings;


# --------------------------------------------------
# BFS
# --------------------------------------------------

sub bfs {

    my ($grid,$start)=@_;

    my $h = @$grid;
    my $w = length($grid->[0]);

    my %dist;

    my @queue;
    my $head = 0;


    my ($sx,$sy)=@$start;

    my $start_key = $sy*$w+$sx;

    $dist{$start_key}=0;

    push @queue, [$sx,$sy];


    while ($head < @queue) {

        my ($x,$y)=@{$queue[$head++]};

        my $cur = $dist{$y*$w+$x};


        for my $d (
            [1,0],
            [-1,0],
            [0,1],
            [0,-1]
        ) {

            my ($dx,$dy)=@$d;

            my $nx=$x+$dx;
            my $ny=$y+$dy;


            next if $nx < 0 || $nx >= $w;
            next if $ny < 0 || $ny >= $h;


            next if substr($grid->[$ny],$nx,1) eq "#";


            my $key=$ny*$w+$nx;


            next if exists $dist{$key};


            $dist{$key}=$cur+1;

            push @queue,[$nx,$ny];
        }
    }


    return \%dist;
}



# --------------------------------------------------
# Manhattan offsets
# --------------------------------------------------

sub make_offsets {

    my ($limit)=@_;

    my @out;


    for my $dx (-$limit .. $limit) {

        for my $dy (-$limit .. $limit) {

            my $md=abs($dx)+abs($dy);

            push @out,[$dx,$dy,$md]
                if $md <= $limit;
        }
    }

    return \@out;
}



# --------------------------------------------------
# Fast cheat counter
# --------------------------------------------------

sub count_cheats {

    my (
        $cells,
        $dist_start,
        $dist_end,
        $best,
        $limit,
        $w
    )=@_;


    my $offsets=make_offsets($limit);


    my $ans=0;


    for my $key (@$cells) {


        my $x=$key % $w;
        my $y=int($key/$w);


        my $base=$dist_start->{$key};


        for my $o (@$offsets) {


            my ($dx,$dy,$jump)=@$o;


            my $nx=$x+$dx;
            my $ny=$y+$dy;


            next if $nx<0 || $ny<0;


            my $dest=$ny*$w+$nx;


            next unless exists $dist_end->{$dest};


            my $new =
                $base
                + $jump
                + $dist_end->{$dest};


            $ans++
                if $best-$new >=100;
        }
    }


    return $ans;
}



# --------------------------------------------------
# Solve
# --------------------------------------------------

sub solve {

    my ($text)=@_;


    my @grid=grep { length } split /\n/,$text;


    my $h=@grid;
    my $w=length($grid[0]);


    my ($start,$end);


    for my $y (0..$h-1) {

        for my $x (0..$w-1) {

            my $c=substr($grid[$y],$x,1);


            if ($c eq "S") {
                $start=[$x,$y];
            }
            elsif ($c eq "E") {
                $end=[$x,$y];
            }
        }
    }


    my $dist_start=bfs(\@grid,$start);
    my $dist_end=bfs(\@grid,$end);



    my $endkey=$end->[1]*$w+$end->[0];

    my $best=$dist_start->{$endkey};



    # intersection of both BFS maps

    my @path_cells;


    for my $key (keys %$dist_start) {

        push @path_cells,$key
            if exists $dist_end->{$key};
    }



    my $p1=count_cheats(
        \@path_cells,
        $dist_start,
        $dist_end,
        $best,
        2,
        $w
    );


    my $p2=count_cheats(
        \@path_cells,
        $dist_start,
        $dist_end,
        $best,
        20,
        $w
    );


    return ($p1,$p2);
}



# --------------------------------------------------
# Main
# --------------------------------------------------

my $file=$ARGV[0];

open my $fh,"<",$file or die "$file: $!";

local $/;

my $text=<$fh>;

close $fh;


my ($p1,$p2)=solve($text);


print "2024 day20: pl_ans_1: $p1\n";
print "2024 day20: pl_ans_2: $p2\n";
