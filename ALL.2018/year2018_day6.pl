use strict;
use warnings;


open my $fh, "<", $ARGV[0] or die $!;

my @coords;

while (my $line = <$fh>) {

    chomp $line;

    next if $line eq "";

    my ($x, $y) = split /,\s*/, $line;

    push @coords, [$x, $y];
}


sub manhattan {

    my ($a, $b) = @_;

    return abs($a->[0] - $b->[0]) +
           abs($a->[1] - $b->[1]);
}


my ($min_x, $max_x, $min_y, $max_y);

for my $c (@coords) {

    my ($x, $y) = @$c;

    $min_x = $x if !defined($min_x) || $x < $min_x;
    $max_x = $x if !defined($max_x) || $x > $max_x;

    $min_y = $y if !defined($min_y) || $y < $min_y;
    $max_y = $y if !defined($max_y) || $y > $max_y;
}


# -----------------------------------------
# Part 1
# -----------------------------------------

my %area;
my %infinite;


for my $c (@coords) {
    $area{"$c->[0],$c->[1]"} = 0;
}


for my $x ($min_x .. $max_x) {

    for my $y ($min_y .. $max_y) {

        my @dists;

        for my $c (@coords) {

            push @dists, [
                manhattan([$x,$y], $c),
                $c
            ];
        }


        @dists = sort {
               $a->[0] <=> $b->[0]
        } @dists;


        next if $dists[0][0] == $dists[1][0];


        my $closest = $dists[0][1];

        $area{"$closest->[0],$closest->[1]"}++;


        if ($x == $min_x ||
            $x == $max_x ||
            $y == $min_y ||
            $y == $max_y) {

            $infinite{"$closest->[0],$closest->[1]"} = 1;
        }
    }
}


my $p1 = 0;

for my $c (@coords) {

    my $key = "$c->[0],$c->[1]";

    next if exists $infinite{$key};

    if ($area{$key} > $p1) {
        $p1 = $area{$key};
    }
}


# -----------------------------------------
# Part 2
# -----------------------------------------

my $region = 0;
my $threshold = 10000;


for my $x ($min_x .. $max_x) {

    for my $y ($min_y .. $max_y) {

        my $total = 0;

        for my $c (@coords) {

            $total += manhattan([$x,$y], $c);
        }


        if ($total < $threshold) {
            $region++;
        }
    }
}


my $p2 = $region;


print "2018 day6: pl_ans_1: $p1\n";
print "2018 day6: pl_ans_2: $p2\n";
