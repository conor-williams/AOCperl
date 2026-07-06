use strict;
use warnings;
use List::Util qw(min);

open my $fh, "<", $ARGV[0] or die $!;
my @lines = <$fh>;
chomp @lines;

# ----------------------------
# PARSE
# ----------------------------
sub parse {
    my (@lines) = @_;
    my @floors;

    for my $i (0..3) {
        $floors[$i] = [];
    }

    for my $i (0..$#lines) {
        my $line = $lines[$i];

        while ($line =~ /(\w+)-compatible microchip/g) {
            push @{$floors[$i]}, [$1, "M"];
        }

        while ($line =~ /(\w+) generator/g) {
            push @{$floors[$i]}, [$1, "G"];
        }
    }

    return \@floors;
}

# ----------------------------
# VALIDITY CHECK
# ----------------------------
sub is_valid {
    my ($floor) = @_;

    my %gens;
    for my $it (@$floor) {
        $gens{$it->[0]} = 1 if $it->[1] eq "G";
    }

    return 1 if !%gens;

    for my $it (@$floor) {
        my ($name, $type) = @$it;
        if ($type eq "M" && !$gens{$name}) {
            return 0;
        }
    }

    return 1;
}

# ----------------------------
# CANONICAL STATE (CRITICAL FIX)
# ----------------------------
sub canonical {
    my ($floors, $e) = @_;

    my %map;
    my $id = 0;

    for my $f (0..$#$floors) {
        for my $it (@{$floors->[$f]}) {
            my $name = $it->[0];
            $map{$name} //= $id++;
        }
    }

    my @pairs;

    for my $f (0..$#$floors) {
        for my $it (@{$floors->[$f]}) {
            my ($name, $type) = @$it;
            push @pairs, [$map{$name}, $type, $f];
        }
    }

    @pairs = sort {
        $a->[0] <=> $b->[0] ||
        $a->[1] cmp $b->[1] ||
        $a->[2] <=> $b->[2]
    } @pairs;

    return join("|", $e, map { join(",", @$_) } @pairs);
}

# ----------------------------
# GOAL CHECK
# ----------------------------
sub is_goal {
    my ($floors) = @_;

    for my $i (0..2) {
        return 0 if @{$floors->[$i]} > 0;
    }
    return 1;
}

# ----------------------------
# BFS SOLVER
# ----------------------------
sub solve {
    my ($start) = @_;

    my @queue = ([0, $start, 0]);
    my %seen;

    while (@queue) {
        my ($floor, $floors, $steps) = @{shift @queue};

        return $steps if is_goal($floors);

        my $state = canonical($floors, $floor);
        next if $seen{$state}++;

        my @items = @{$floors->[$floor]};

        for my $i (0..$#items) {
            for my $j ($i..$#items) {

                my @move = ($i == $j) ? ($items[$i]) : ($items[$i], $items[$j]);

                for my $d (-1, 1) {
                    my $nf = $floor + $d;
                    next if $nf < 0 || $nf > 3;

                    my @new = map { [@$_] } @$floors;

                    for my $m (@move) {
                        my $idx = 0;
                        for my $k (0..$#{$new[$floor]}) {
                            if ($new[$floor][$k][0] eq $m->[0] &&
                                $new[$floor][$k][1] eq $m->[1]) {
                                splice(@{$new[$floor]}, $k, 1);
                                last;
                            }
                        }
                        push @{$new[$nf]}, $m;
                    }

                    if (is_valid($new[$floor]) && is_valid($new[$nf])) {
                        push @queue, [$nf, \@new, $steps + 1];
                    }
                }
            }
        }
    }

    return -1;
}

# ----------------------------
# MAIN
# ----------------------------
my $base = parse(@lines);

# PART 1
my $p1 = solve($base);

# PART 2 (extra items)
my @base2 = map { [@$_] } @$base;

for my $e ("elerium", "dilithium") {
    push @{$base2[0]}, [$e, "M"];
    push @{$base2[0]}, [$e, "G"];
}

my $p2 = solve(\@base2);

print "2016 day11: pl_ans_1: $p1\n";
print "2016 day11: pl_ans_2: $p2\n";
