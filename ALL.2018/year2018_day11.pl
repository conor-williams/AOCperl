use strict;
use warnings;

sub power {
    my ($x, $y, $serial) = @_;

    my $rack = $x + 10;
    my $p = $rack * $y;
    $p += $serial;
    $p *= $rack;

    return int($p / 100) % 10 - 5;
}

sub build_grid {
    my ($serial) = @_;

    my @grid;

    for my $y (0 .. 300) {
        for my $x (0 .. 300) {
            $grid[$y][$x] = 0;
        }
    }

    for my $y (1 .. 300) {
        for my $x (1 .. 300) {
            $grid[$y][$x] = power($x, $y, $serial);
        }
    }

    return \@grid;
}

sub sat {
    my ($grid) = @_;

    my @s;

    for my $y (0 .. 300) {
        for my $x (0 .. 300) {
            $s[$y][$x] = 0;
        }
    }

    for my $y (1 .. 300) {
        my $row = 0;

        for my $x (1 .. 300) {
            $row += $grid->[$y][$x];
            $s[$y][$x] = $s[$y-1][$x] + $row;
        }
    }

    return \@s;
}

sub square_sum {
    my ($s, $x, $y, $k) = @_;

    my $x2 = $x + $k - 1;
    my $y2 = $y + $k - 1;

    return
        $s->[$y2][$x2]
      - $s->[$y-1][$x2]
      - $s->[$y2][$x-1]
      + $s->[$y-1][$x-1];
}

sub main {

    open(my $fh, "<", $ARGV[0]) or die $!;

    my $serial = <$fh>;
    chomp $serial;

    close($fh);

    my $grid = build_grid($serial);
    my $s = sat($grid);

    # ---------------- Part 1 ----------------

    my $best_val = -1e9;
    my ($bx, $by);

    for my $y (1 .. 297) {
        for my $x (1 .. 297) {

            my $v = square_sum($s, $x, $y, 3);

            if ($v > $best_val) {
                $best_val = $v;
                $bx = $x;
                $by = $y;
            }
        }
    }

    my $p1 = "$bx,$by";

    # ---------------- Part 2 ----------------

    $best_val = -1e9;
    my ($bestx, $besty, $bestk);

    for my $k (1 .. 300) {
        for my $y (1 .. 300 - $k) {
            for my $x (1 .. 300 - $k) {

                my $v = square_sum($s, $x, $y, $k);

                if ($v > $best_val) {
                    $best_val = $v;
                    $bestx = $x;
                    $besty = $y;
                    $bestk = $k;
                }
            }
        }
    }

    my $p2 = "$bestx,$besty,$bestk";

    print "2018 day11: pl_ans_1: $p1\n";
    print "2018 day11: pl_ans_2: $p2\n";
}

main();
