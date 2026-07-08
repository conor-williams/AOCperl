#!/usr/bin/perl
use strict;
use warnings;

my $file = shift;

open(my $fh, "<", $file) or die $!;

my %contains;
my %inside;

while (<$fh>) {
    chomp;
    next unless length;

    my ($outer, $rest) = split(/ bags contain /);

    next if $rest =~ /no other bags/;

    while ($rest =~ /(\d+) ([a-z ]+) bag/g) {

        my ($qty, $color) = ($1, $2);

        push @{$contains{$outer}}, [$qty, $color];
        push @{$inside{$color}}, $outer;
    }
}

close($fh);

# -------------------------
# Part 1
# -------------------------

my %seen;
my @stack = ("shiny gold");

while (@stack) {

    my $bag = pop @stack;

    next unless exists $inside{$bag};

    foreach my $parent (@{$inside{$bag}}) {

        next if $seen{$parent};

        $seen{$parent} = 1;
        push @stack, $parent;
    }
}

my $p1 = scalar(keys %seen);

# -------------------------
# Part 2
# -------------------------

my %memo;

sub count {
    my ($bag) = @_;

    return $memo{$bag} if exists $memo{$bag};

    my $total = 0;

    if (exists $contains{$bag}) {

        foreach my $entry (@{$contains{$bag}}) {

            my ($qty, $child) = @$entry;

            $total += $qty * (1 + count($child));
        }
    }

    $memo{$bag} = $total;

    return $total;
}

my $p2 = count("shiny gold");

print "2020 day7: pl_ans_1: $p1\n";
print "2020 day7: pl_ans_2: $p2\n";
