use strict;
use warnings;


my $path = $ARGV[0];

open my $fh, '<', $path or die "$path: $!";

my @grid;

while (<$fh>) {
    chomp;
    next if /^\s*$/;

    push @grid, [map { int($_) } split //];
}

close $fh;


my $h = scalar @grid;
my $w = scalar @{$grid[0]};


my @dirs = (
    [1,0],
    [-1,0],
    [0,1],
    [0,-1],
);


my $p1 = 0;
my $p2 = 0;


for my $y (0 .. $h-1) {
    for my $x (0 .. $w-1) {

        next unless $grid[$y][$x] == 0;


        # ---------------- Part 1 ----------------

        my @stack = ([$x,$y]);
        my %seen;
        my %peaks;

        while (@stack) {

            my ($cx,$cy) = @{pop @stack};

            if ($grid[$cy][$cx] == 9) {
                $peaks{"$cx,$cy"} = 1;
                next;
            }


            for my $d (@dirs) {

                my ($dx,$dy) = @$d;

                my $nx = $cx + $dx;
                my $ny = $cy + $dy;

                next if $nx < 0 || $nx >= $w;
                next if $ny < 0 || $ny >= $h;

                next unless $grid[$ny][$nx] == $grid[$cy][$cx] + 1;

                my $key = "$nx,$ny";

                next if $seen{$key};

                $seen{$key} = 1;
                push @stack, [$nx,$ny];
            }
        }


        $p1 += scalar keys %peaks;


        # ---------------- Part 2 ----------------

        @stack = ([$x,$y]);

        my $rating = 0;


        while (@stack) {

            my ($cx,$cy) = @{pop @stack};


            if ($grid[$cy][$cx] == 9) {
                $rating++;
                next;
            }


            for my $d (@dirs) {

                my ($dx,$dy) = @$d;

                my $nx = $cx + $dx;
                my $ny = $cy + $dy;

                next if $nx < 0 || $nx >= $w;
                next if $ny < 0 || $ny >= $h;

                next unless $grid[$ny][$nx] == $grid[$cy][$cx] + 1;

                push @stack, [$nx,$ny];
            }
        }


        $p2 += $rating;
    }
}


print "2024 day10: pl_ans_1: $p1\n";
print "2024 day10: pl_ans_2: $p2\n";
