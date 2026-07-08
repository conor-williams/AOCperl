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


my $h = scalar @grid;
my $w = scalar @{$grid[0]};


sub neighbors {

    my ($x, $y, $w, $h) = @_;

    my @out;

    my @dirs = (
        [1,0],
        [-1,0],
        [0,1],
        [0,-1]
    );

    for my $d (@dirs) {

        my ($nx, $ny) = ($x + $d->[0], $y + $d->[1]);

        if ($nx >= 0 && $nx < $w &&
            $ny >= 0 && $ny < $h) {

            push @out, [$nx, $ny];
        }
    }

    return @out;
}


# ---------------- Part 1 ----------------

my @low_points;

for my $y (0 .. $h-1) {

    for my $x (0 .. $w-1) {

        my $v = $grid[$y][$x];

        my $low = 1;

        for my $n (neighbors($x,$y,$w,$h)) {

            my ($nx,$ny) = @$n;

            if ($v >= $grid[$ny][$nx]) {
                $low = 0;
                last;
            }
        }

        if ($low) {
            push @low_points, [$x,$y,$v];
        }
    }
}


my $p1 = 0;

for my $p (@low_points) {
    $p1 += $p->[2] + 1;
}



# ---------------- Part 2 ----------------

my %visited;

my @basin_sizes;


for my $lp (@low_points) {

    my ($sx,$sy) = @$lp;

    next if exists $visited{"$sx,$sy"};


    my @queue = ([$sx,$sy]);
    my %basin;


    while (@queue) {

        my $cur = shift @queue;

        my ($x,$y) = @$cur;

        next if exists $visited{"$x,$y"};

        $visited{"$x,$y"} = 1;


        next if $grid[$y][$x] == 9;


        $basin{"$x,$y"} = 1;


        for my $n (neighbors($x,$y,$w,$h)) {

            my ($nx,$ny) = @$n;

            next if exists $visited{"$nx,$ny"};
            next if $grid[$ny][$nx] == 9;

            push @queue, [$nx,$ny];
        }
    }


    push @basin_sizes, scalar(keys %basin);
}


@basin_sizes = sort { $b <=> $a } @basin_sizes;


my $p2 = $basin_sizes[0] *
         $basin_sizes[1] *
         $basin_sizes[2];


print "2021 day9: pl_ans_1: $p1\n";
print "2021 day9: pl_ans_2: $p2\n";
