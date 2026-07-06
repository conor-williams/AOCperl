use strict;
use warnings;
use List::Util qw(sum);

my $W = 50;
my $H = 6;

my $path = $ARGV[0];
open my $fh, '<', $path or die $!;

my @grid;
for my $y (0 .. $H - 1) {
    for my $x (0 .. $W - 1) {
        $grid[$y][$x] = 0;
    }
}

while (my $line = <$fh>) {
    chomp $line;
    next if $line eq "";

    if ($line =~ /^rect (\d+)x(\d+)/) {
        my ($a, $b) = ($1, $2);

        for my $y (0 .. $b - 1) {
            for my $x (0 .. $a - 1) {
                $grid[$y][$x] = 1;
            }
        }
    }
    elsif ($line =~ /^rotate row y=(\d+) by (\d+)/) {
        my ($y, $n) = ($1, $2);
        my @new;

        for my $x (0 .. $W - 1) {
            $new[($x + $n) % $W] = $grid[$y][$x];
        }

        $grid[$y] = \@new;
    }
    elsif ($line =~ /^rotate column x=(\d+) by (\d+)/) {
        my ($x, $n) = ($1, $2);
        my @new;

        for my $y (0 .. $H - 1) {
            $new[($y + $n) % $H] = $grid[$y][$x];
        }

        for my $y (0 .. $H - 1) {
            $grid[$y][$x] = $new[$y];
        }
    }
}

# Part 1
my $p1 = 0;
for my $row (@grid) {
    $p1 += sum(@$row);
}

print "2016 day8: pl_ans_1: $p1\n";
print "2016 day8: pl_ans_2:\n";

for my $row (@grid) {
    print join("", map { $_ ? "#" : "." } @$row), "\n";
}
