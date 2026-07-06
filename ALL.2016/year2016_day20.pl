use strict;
use warnings;

my $MAX_IP = 4294967295;

open my $fh, "<", $ARGV[0] or die $!;
my @lines = <$fh>;
chomp @lines;

# ----------------------------
# parse
# ----------------------------
sub parse {
    my (@lines) = @_;
    my @ranges;

    for my $line (@lines) {
        my ($a, $b) = split /-/, $line;
        push @ranges, [$a+0, $b+0];
    }

    @ranges = sort { $a->[0] <=> $b->[0] } @ranges;
    return @ranges;
}

# ----------------------------
# merge
# ----------------------------
sub merge_ranges {
    my (@ranges) = @_;
    my @merged;

    for my $r (@ranges) {
        my ($start, $end) = @$r;

        if (!@merged || $start > $merged[-1]->[1] + 1) {
            push @merged, [$start, $end];
        }
        else {
            if ($end > $merged[-1]->[1]) {
                $merged[-1]->[1] = $end;
            }
        }
    }

    return @merged;
}

# ----------------------------
# main solve (same structure as Python)
# ----------------------------
sub solve {
    my (@lines) = @_;

    my @ranges = parse(@lines);
    my @merged = merge_ranges(@ranges);

    # --------------------
    # part 1
    # --------------------
    my $lowest = 0;

    for my $r (@merged) {
        my ($start, $end) = @$r;

        if ($lowest < $start) {
            last;
        }

        if ($end + 1 > $lowest) {
            $lowest = $end + 1;
        }
    }

    # --------------------
    # part 2
    # --------------------
    my $allowed = 0;
    my $cur = 0;

    for my $r (@merged) {
        my ($start, $end) = @$r;

        if ($cur < $start) {
            $allowed += ($start - $cur);
        }

        if ($end + 1 > $cur) {
            $cur = $end + 1;
        }
    }

    if ($cur <= $MAX_IP) {
        $allowed += ($MAX_IP - $cur + 1);
    }

    return ($lowest, $allowed);
}

# ----------------------------
# run
# ----------------------------
my ($p1, $p2) = solve(@lines);

print "2016 day20: pl_ans_1: $p1\n";
print "2016 day20: pl_ans_2: $p2\n";
