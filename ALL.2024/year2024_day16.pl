use strict;
use warnings;
use List::Util qw(min);


my @DIRS = (
    [1,0],    # East
    [0,1],    # South
    [-1,0],   # West
    [0,-1],   # North
);


sub parse_grid {
    my ($grid) = @_;

    my ($start, $end);

    for my $y (0 .. $#$grid) {
        my @row = split //, $grid->[$y];

        for my $x (0 .. $#row) {
            if ($row[$x] eq "S") {
                $start = [$x,$y];
            }
            elsif ($row[$x] eq "E") {
                $end = [$x,$y];
            }
        }
    }

    return ($start,$end);
}


sub solve {

    my ($grid) = @_;

    my ($start,$end) = parse_grid($grid);

    my $h = @$grid;
    my $w = length($grid->[0]);


    # simple binary heap implementation
    my @pq = ([0,$start->[0],$start->[1],0]);


    my %dist;

    my $best_end_cost = 1e99;


    while (@pq) {

        # extract minimum
        my $best = 0;

        for my $i (1 .. $#pq) {
            $best = $i if $pq[$i][0] < $pq[$best][0];
        }

        my ($cost,$x,$y,$d) = @{splice(@pq,$best,1)};


        my $key = "$x,$y,$d";

        next if exists $dist{$key};

        $dist{$key} = $cost;


        if ($x == $end->[0] && $y == $end->[1]) {
            $best_end_cost = $cost
                if $cost < $best_end_cost;
        }


        # forward

        my ($dx,$dy)=@{$DIRS[$d]};

        my ($nx,$ny)=($x+$dx,$y+$dy);


        if ($nx >= 0 && $nx < $w &&
            $ny >= 0 && $ny < $h &&
            substr($grid->[$ny],$nx,1) ne "#") {

            push @pq, [$cost+1,$nx,$ny,$d];
        }


        # turns

        push @pq, [
            $cost+1000,
            $x,
            $y,
            ($d+1)%4
        ];

        push @pq, [
            $cost+1000,
            $x,
            $y,
            ($d+3)%4
        ];
    }


    # Part 2

    my @queue;
    my %visited;


    for my $key (keys %dist) {

        my ($x,$y,$d)=split /,/,$key;

        if ($x==$end->[0] &&
            $y==$end->[1] &&
            $dist{$key}==$best_end_cost) {

            push @queue, [$x,$y,$d];
            $visited{$key}=1;
        }
    }


    my %best_tiles;


    while (@queue) {

        my ($x,$y,$d)=@{pop @queue};

        $best_tiles{"$x,$y"}=1;

        my $cost=$dist{"$x,$y,$d"};


        # reverse forward

        my ($dx,$dy)=@{$DIRS[$d]};

        my ($px,$py)=($x-$dx,$y-$dy);

        my $prev="$px,$py,$d";

        if (exists $dist{$prev} &&
            $dist{$prev}==$cost-1 &&
            !$visited{$prev}) {

            $visited{$prev}=1;
            push @queue,[$px,$py,$d];
        }


        # reverse turns

        for my $nd (($d+1)%4,($d+3)%4) {

            my $prev="$x,$y,$nd";

            if (exists $dist{$prev} &&
                $dist{$prev}==$cost-1000 &&
                !$visited{$prev}) {

                $visited{$prev}=1;
                push @queue,[$x,$y,$nd];
            }
        }
    }


    return ($best_end_cost, scalar keys %best_tiles);
}


my $path=$ARGV[0];

open my $fh,'<',$path or die "$path: $!";

my @grid;

while (<$fh>) {
    chomp;
    push @grid,$_;
}

close $fh;


my ($p1,$p2)=solve(\@grid);

print "2024 day16: pl_ans_1: $p1\n";
print "2024 day16: pl_ans_2: $p2\n";
