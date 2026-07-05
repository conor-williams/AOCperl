#!/usr/bin/env perl
use strict;
use warnings;

my $s = <>;
chomp $s;

sub look_and_say {
    my @a = split //, shift;
    my @out;

    my $i = 0;
    my $n = @a;

    while ($i < $n) {

        my $j = $i;

        while ($j < $n && $a[$j] eq $a[$i]) {
            $j++;
        }

        my $count = $j - $i;

        push @out, $count, $a[$i];

        $i = $j;
    }

    return join("", @out);
}

# -------------------
# Part 1
# -------------------
for (1..40) {
    $s = look_and_say($s);
}

my $p1 = length($s);

# -------------------
# Part 2
# -------------------
for (1..10) {
    $s = look_and_say($s);
}

my $p2 = length($s);

print "2015 day10: pl_ans_1: $p1\n";
print "2015 day10: pl_ans_2: $p2\n";
