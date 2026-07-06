use strict;
use warnings;

open my $fh, "<", $ARGV[0] or die $!;
my ($fav) = <$fh>;
chomp $fav;

# ----------------------------
# EXACT PYTHON WALL FUNCTION
# ----------------------------
sub is_wall {
    my ($x, $y) = @_;

    return 1 if $x < 0 or $y < 0;

    my $n = $x*$x + 3*$x + 2*$x*$y + $y + $y*$y + $fav;

    my $bin = sprintf("%b", $n);
    my $ones = ($bin =~ tr/1/1/);

    return $ones % 2 == 1;
}

# ----------------------------
# BFS INITIAL STATE (Python deque equivalent)
# ----------------------------
my @q = ([1, 1, 0]);   # x, y, steps
my %seen;
$seen{"1,1"} = 1;

my $p1;
my $p2 = 0;

# ----------------------------
# BFS LOOP (EXACT STRUCTURE)
# ----------------------------
while (@q) {

    my ($x, $y, $d) = @{ shift @q };

    # ----------------------------
    # PART 1
    # ----------------------------
    if (!defined $p1 && $x == 31 && $y == 39) {
        $p1 = $d;
    }

    # ----------------------------
    # PART 2
    # ----------------------------
    if ($d <= 50) {
        $p2++;
    }

    # ----------------------------
    # NEIGHBOURS
    # ----------------------------
    my @dirs = ([1,0],[-1,0],[0,1],[0,-1]);

    for my $dir (@dirs) {

        my ($nx, $ny) = ($x + $dir->[0], $y + $dir->[1]);

        next if is_wall($nx, $ny);

        my $key = "$nx,$ny";

        next if $seen{$key};

        $seen{$key} = 1;
        push @q, [$nx, $ny, $d + 1];
    }
}

# ----------------------------
# OUTPUT (same style)
# ----------------------------
print "2016 day13: pl_ans_1: $p1\n";
print "2016 day13: pl_ans_2: $p2\n";
