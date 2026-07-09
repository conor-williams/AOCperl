use strict;
use warnings;

sub count_xmas {
    my ($grid, $x, $y, $dx, $dy) = @_;

    my $target = "XMAS";

    for my $i (0 .. 3) {
        my $nx = $x + $dx * $i;
        my $ny = $y + $dy * $i;

        return 0 if $ny < 0 || $ny >= @$grid;
        return 0 if $nx < 0 || $nx >= @{$grid->[0]};

        return 0 if $grid->[$ny][$nx] ne substr($target, $i, 1);
    }

    return 1;
}


sub is_x_mas {
    my ($grid, $x, $y) = @_;

    # centre must be A
    return 0 unless $grid->[$y][$x] eq "A";

    my $h = @$grid;
    my $w = @{$grid->[0]};

    return 0 if $x - 1 < 0 || $x + 1 >= $w;
    return 0 if $y - 1 < 0 || $y + 1 >= $h;

    my $tl = $grid->[$y-1][$x-1];
    my $tr = $grid->[$y-1][$x+1];
    my $bl = $grid->[$y+1][$x-1];
    my $br = $grid->[$y+1][$x+1];

    my @diag1 = sort ($tl, $br);
    my @diag2 = sort ($tr, $bl);

    return (@diag1 == 2 &&
            $diag1[0] eq "M" &&
            $diag1[1] eq "S" &&
            $diag2[0] eq "M" &&
            $diag2[1] eq "S");
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

my @dirs = (
    [ 1, 0 ], [-1, 0],
    [ 0, 1 ], [ 0,-1],
    [ 1, 1 ], [ 1,-1],
    [-1, 1 ], [-1,-1],
);

# Part 1
my $p1 = 0;

for my $y (0 .. $h-1) {
    for my $x (0 .. $w-1) {
        for my $d (@dirs) {
            $p1 += count_xmas(
                \@grid,
                $x,
                $y,
                $d->[0],
                $d->[1]
            );
        }
    }
}

# Part 2
my $p2 = 0;

for my $y (1 .. $h-2) {
    for my $x (1 .. $w-2) {
        $p2++ if is_x_mas(\@grid, $x, $y);
    }
}

print "2024 day4: pl_ans_1: $p1\n";
print "2024 day4: pl_ans_2: $p2\n";
