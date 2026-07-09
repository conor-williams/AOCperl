use strict;
use warnings;


sub in_bounds {
    my ($x, $y, $w, $h) = @_;

    return $x >= 0 && $x < $w &&
           $y >= 0 && $y < $h;
}


my $path = $ARGV[0];

open my $fh, '<', $path or die "$path: $!";

my @grid;

while (<$fh>) {
    chomp;
    next if /^\s*$/;

    push @grid, [split //];
}

close $fh;


my $h = scalar @grid;
my $w = scalar @{$grid[0]};


my %ants;

for my $y (0 .. $h-1) {
    for my $x (0 .. $w-1) {

        my $c = $grid[$y][$x];

        if ($c ne ".") {
            push @{$ants{$c}}, [$x, $y];
        }
    }
}


# ---------------- Part 1 ----------------

my %antinodes1;


for my $freq (keys %ants) {

    my $pts = $ants{$freq};
    my $n = @$pts;

    for my $i (0 .. $n-1) {

        my ($x1, $y1) = @{$pts->[$i]};

        for my $j ($i+1 .. $n-1) {

            my ($x2, $y2) = @{$pts->[$j]};

            my $dx = $x2 - $x1;
            my $dy = $y2 - $y1;

            my ($ax1, $ay1) = ($x1 - $dx, $y1 - $dy);
            my ($ax2, $ay2) = ($x2 + $dx, $y2 + $dy);


            if (in_bounds($ax1, $ay1, $w, $h)) {
                $antinodes1{"$ax1,$ay1"} = 1;
            }

            if (in_bounds($ax2, $ay2, $w, $h)) {
                $antinodes1{"$ax2,$ay2"} = 1;
            }
        }
    }
}


my $p1 = scalar keys %antinodes1;


# ---------------- Part 2 ----------------

my %antinodes2;


for my $freq (keys %ants) {

    my $pts = $ants{$freq};
    my $n = @$pts;

    for my $i (0 .. $n-1) {

        my ($x1, $y1) = @{$pts->[$i]};

        for my $j ($i+1 .. $n-1) {

            my ($x2, $y2) = @{$pts->[$j]};

            my $dx = $x2 - $x1;
            my $dy = $y2 - $y1;


            # walk backwards
            my ($x, $y) = ($x1, $y1);

            while (in_bounds($x, $y, $w, $h)) {

                $antinodes2{"$x,$y"} = 1;

                $x -= $dx;
                $y -= $dy;
            }


            # walk forwards
            ($x, $y) = ($x2, $y2);

            while (in_bounds($x, $y, $w, $h)) {

                $antinodes2{"$x,$y"} = 1;

                $x += $dx;
                $y += $dy;
            }
        }
    }
}


my $p2 = scalar keys %antinodes2;


print "2024 day8: pl_ans_1: $p1\n";
print "2024 day8: pl_ans_2: $p2\n";
