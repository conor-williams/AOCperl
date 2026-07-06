use strict;
use warnings;

use List::Util qw(max);

open my $fh, "<", $ARGV[0] or die $!;

# ----------------------------
# PARSE
# ----------------------------
my %d_nodes;

while (my $line = <$fh>) {
    chomp $line;

    next unless $line =~ m{node-x(\d+)-y(\d+)};

    my ($x,$y,$size,$used,$avail,$pct) = ($line =~ /\d+/g);

    $d_nodes{"$x,$y"} = {
        used  => $used,
        avail => $avail,
    };
}

# ----------------------------
# GRID SIZE
# ----------------------------
my $lx = max(map { (split /,/, $_)[0] } keys %d_nodes) + 1;
my $ly = max(map { (split /,/, $_)[1] } keys %d_nodes) + 1;

# ----------------------------
# PART 1 (exact)
# ----------------------------
my @vals = values %d_nodes;
my $cnt = 0;

for my $i (0..$#vals) {
    for my $j ($i+1..$#vals) {

        if ($vals[$i]{used} != 0 && $vals[$i]{used} <= $vals[$j]{avail}) {
            $cnt++;
        }

        if ($vals[$j]{used} != 0 && $vals[$j]{used} <= $vals[$i]{avail}) {
            $cnt++;
        }
    }
}

print "2016 day22: pl_ans_1: $cnt\n";

# ----------------------------
# BFS (same logic as Python)
# ----------------------------
sub bfs {
    my ($start, $target, $block) = @_;

    my @q = ($start);
    my %dist = ($start => 0);

    while (@q) {
        my $n = shift @q;

        return $dist{$n} if $n eq $target;

        my ($x,$y) = split /,/, $n;

        for my $d ([1,0],[-1,0],[0,1],[0,-1]) {

            my ($nx,$ny) = ($x + $d->[0], $y + $d->[1]);

            next if $nx < 0 || $ny < 0 || $nx >= $lx || $ny >= $ly;

            my $k = "$nx,$ny";

            next if $d_nodes{$k}{used} >= 100;
            next if defined $block && $k eq $block;

            next if exists $dist{$k};

            $dist{$k} = $dist{$n} + 1;
            push @q, $k;
        }
    }

    return 1e9;
}

# ----------------------------
# INITIAL STATE
# ----------------------------
my $start = "0,0";
my $goal  = ($lx - 1) . ",0";

my $empty;
for my $k (keys %d_nodes) {
    if ($d_nodes{$k}{used} == 0) {
        $empty = $k;
        last;
    }
}

die "No empty node found\n" unless defined $empty;

# ----------------------------
# PATH FROM GOAL TO START
# ----------------------------
my @path = ();

{
    # build full path like Python BFS usage intent
    my @q = ($goal);
    my %prev;
    my %seen = ($goal => 1);

    while (@q) {
        my $n = shift @q;

        last if $n eq $start;

        my ($x,$y) = split /,/, $n;

        for my $d ([1,0],[-1,0],[0,1],[0,-1]) {

            my ($nx,$ny) = ($x+$d->[0], $y+$d->[1]);
            next if $nx < 0 || $ny < 0 || $nx >= $lx || $ny >= $ly;

            my $k = "$nx,$ny";
            next if $seen{$k};
            next if $d_nodes{$k}{used} >= 100;

            $seen{$k} = 1;
            $prev{$k} = $n;
            push @q, $k;
        }
    }

    my $cur = $start;
    my @rev;
    while ($cur && $cur ne $goal) {
        push @rev, $cur;
        $cur = $prev{$cur};
    }

    @path = reverse @rev;
}

# ----------------------------
# PART 2 (exact simulation)
# ----------------------------
my $steps = 0;

while ($goal ne $start) {

    my $target = shift @path;
    last unless defined $target;

    my $d = bfs($empty, $target, $goal);
    $steps += $d + 1;

    $empty = $goal;
    $goal  = $target;
}

print "2016 day22: pl_ans_2: $steps\n";
