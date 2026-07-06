use strict;
use warnings;
use List::Util qw(min);

open my $fh, "<", $ARGV[0] or die $!;
my @grid = <$fh>;
chomp @grid;

my $H = @grid;
my $W = length($grid[0]);

# ----------------------------
# Parse points
# ----------------------------
my %points;

for my $y (0..$H-1) {
    for my $x (0..$W-1) {
        my $c = substr($grid[$y], $x, 1);
        $points{$c} = [$x, $y] if $c =~ /\d/;
    }
}

# ----------------------------
# BFS
# ----------------------------
sub bfs {
    my ($sx, $sy) = @_;

    my @q = ([$sx, $sy, 0]);
    my %seen = ("$sx,$sy" => 1);
    my %dist;

    while (@q) {
        my ($x,$y,$d) = @{shift @q};

        my $c = substr($grid[$y], $x, 1);
        $dist{$c} = $d if $c =~ /\d/;

        for my $p ([1,0],[-1,0],[0,1],[0,-1]) {
            my ($nx,$ny) = ($x+$p->[0], $y+$p->[1]);

            next if $nx < 0 || $ny < 0 || $nx >= $W || $ny >= $H;
            next if substr($grid[$ny], $nx, 1) eq '#';
            next if $seen{"$nx,$ny"}++;

            push @q, [$nx,$ny,$d+1];
        }
    }

    return \%dist;
}

# ----------------------------
# Build distances
# ----------------------------
my %dist;
for my $k (keys %points) {
    my ($x,$y) = @{$points{$k}};
    $dist{$k} = bfs($x,$y);
}

# ----------------------------
# PRECOMPUTE KEYS + INDEX
# ----------------------------
my @keys = sort keys %dist;
my %idx;
$idx{$keys[$_]} = $_ for 0..$#keys;

my $start = "0";

# ----------------------------
# DP (OUTSIDE sub = FIX)
# ----------------------------
my %memo;

sub dp {
    my ($pos, $mask, $return_to_start) = @_;

    if ($mask == (1 << scalar @keys) - 1) {
        return $return_to_start
            ? $dist{$pos}{$start}
            : 0;
    }

    my $key = "$pos|$mask|$return_to_start";
    return $memo{$key} if exists $memo{$key};

    my $best = 1e9;

    for my $nxt (@keys) {
        next if $mask & (1 << $idx{$nxt});

        my $cost = $dist{$pos}{$nxt}
                 + dp($nxt, $mask | (1 << $idx{$nxt}), $return_to_start);

        $best = $cost if $cost < $best;
    }

    return $memo{$key} = $best;
}

# ----------------------------
# SOLVE
# ----------------------------
my $p1 = dp($start, 1 << $idx{$start}, 0);
%memo = ();
my $p2 = dp($start, 1 << $idx{$start}, 1);

print "2016 day24: pl_ans_1: $p1\n";
print "2016 day24: pl_ans_2: $p2\n";
