#!/usr/bin/env perl
use strict;
use warnings;

my $s = <>;
chomp $s;

my @p = map { ord($_) } split //, $s;

# forbidden letters
my %bad = map { $_ => 1 } (105, 111, 108); # i o l

sub increment {

    my $i = $#p;

    while ($i >= 0) {

        $p[$i]++;

        # skip forbidden letters immediately
        while ($bad{$p[$i]}) {
            $p[$i]++;
        }

        if ($p[$i] > 122) {
            $p[$i] = 97;
            $i--;
        } else {
            last;
        }
    }

    # everything after changes resets to 'a'
    for my $j ($i+1 .. $#p) {
        $p[$j] = 97;
    }
}

sub valid {

    # rule 1: no bad letters (fast reject)
    for (@p) {
        return 0 if $bad{$_};
    }

    # rule 2: straight of 3
    my $straight = 0;
    for my $i (0 .. $#p - 2) {
        if ($p[$i]+1 == $p[$i+1] && $p[$i]+2 == $p[$i+2]) {
            $straight = 1;
            last;
        }
    }
    return 0 unless $straight;

    # rule 3: two pairs
    my $pairs = 0;
    my $i = 0;

    while ($i < $#p) {
        if ($p[$i] == $p[$i+1]) {
            $pairs++;
            $i += 2;
        } else {
            $i++;
        }
    }

    return $pairs >= 2;
}

sub next_pw {
    while (1) {
        increment();
        return join("", map { chr($_) } @p) if valid();
    }
}

# -------------------
# Part 1
# -------------------
my $p1 = next_pw();

# reset state from p1
@p = map { ord($_) } split //, $p1;

# -------------------
# Part 2
# -------------------
my $p2 = next_pw();

print "2015 day11: pl_ans_1: $p1\n";
print "2015 day11: pl_ans_2: $p2\n";
