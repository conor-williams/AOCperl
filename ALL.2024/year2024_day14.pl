use strict;
use warnings;
use List::Util qw(product);


sub calc_new_position {
    my ($x, $y, $dx, $dy, $w, $h, $seconds) = @_;

    my $x2 = ($x + $dx * $seconds) % $w;
    my $y2 = ($y + $dy * $seconds) % $h;

    $x2 += $w if $x2 < 0;
    $y2 += $h if $y2 < 0;

    return ($x2, $y2);
}


sub calc_quadrant {
    my ($x, $y, $w, $h) = @_;

    my $qx = int($x / ($w / 2));
    my $qy = int($y / ($h / 2));

    my $quad = ($qx < 2) ? $qx + 1 : $qx;

    $quad += 2 if $qy > 0;

    return $quad;
}


my $path = $ARGV[0];

open my $fh, '<', $path or die "$path: $!";
local $/;
my $data = <$fh>;
close $fh;


$data =~ s/^\s+|\s+$//g;


my ($w, $h) = (101, 103);


my @robots;

for my $line (split /\n/, $data) {

    my ($pos, $vel) = split / /, $line;

    my ($x,$y) = $pos =~ /p=(-?\d+),(-?\d+)/;
    my ($dx,$dy) = $vel =~ /v=(-?\d+),(-?\d+)/;

    push @robots, [$x,$y,$dx,$dy];
}


my @quad_counter = (0,0,0,0);
my @neighbors_counter;


for my $i (0 .. 9999) {

    my $neighbors = 0;
    my %positions;


    for my $r (@robots) {

        my ($x,$y,$dx,$dy) = @$r;

        my ($nx,$ny) = calc_new_position(
            $x,$y,$dx,$dy,$w,$h,$i+1
        );

        $positions{"$nx,$ny"} = 1;


        if ($i == 99) {

            next if $nx == int($w/2) ||
                    $ny == int($h/2);

            my $quad = calc_quadrant(
                $nx,$ny,$w,$h
            );

            $quad_counter[$quad-1]++;
        }
    }


    for my $pos (keys %positions) {

        my ($x,$y) = split /,/, $pos;

        for my $n (
            [$x+1,$y],
            [$x-1,$y],
            [$x,$y+1],
            [$x,$y-1]
        ) {

            my ($xx,$yy) = @$n;

            $neighbors++
                if exists $positions{"$xx,$yy"};
        }
    }


    push @neighbors_counter, $neighbors;
}


my $p1 = product(@quad_counter);

my $max = -1;
my $idx = 0;

for my $i (0 .. $#neighbors_counter) {

    if ($neighbors_counter[$i] > $max) {
        $max = $neighbors_counter[$i];
        $idx = $i;
    }
}


print "2024 day14: pl_ans_1: $p1\n";
print "2024 day14: pl_ans_2: ", $idx + 1, "\n";
