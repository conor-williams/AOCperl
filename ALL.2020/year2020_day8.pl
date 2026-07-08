#!/usr/bin/perl
use strict;
use warnings;

sub run {
    my ($program) = @_;

    my $acc = 0;
    my $ip  = 0;
    my %seen;

    while (!exists $seen{$ip} && $ip >= 0 && $ip < @$program) {

        $seen{$ip} = 1;

        my ($op, $arg) = @{$program->[$ip]};

        if ($op eq "acc") {
            $acc += $arg;
            $ip++;
        }
        elsif ($op eq "jmp") {
            $ip += $arg;
        }
        else {          # nop
            $ip++;
        }
    }

    my $terminated = ($ip >= @$program);

    return ($terminated, $acc);
}

my $file = shift;

open(my $fh, "<", $file) or die $!;

my @program;

while (<$fh>) {
    chomp;
    next unless length;

    my ($op, $arg) = split;
    push @program, [$op, int($arg)];
}

close($fh);

# ---------------- Part 1 ----------------

my (undef, $p1) = run(\@program);

# ---------------- Part 2 ----------------

my $p2;

for (my $i = 0; $i < @program; $i++) {

    my ($op, $arg) = @{$program[$i]};

    next if $op eq "acc";

    my @modified = map { [ @$_ ] } @program;

    if ($op eq "jmp") {
        $modified[$i] = ["nop", $arg];
    }
    else {
        $modified[$i] = ["jmp", $arg];
    }

    my ($terminated, $acc) = run(\@modified);

    if ($terminated) {
        $p2 = $acc;
        last;
    }
}

print "2020 day8: pl_ans_1: $p1\n";
print "2020 day8: pl_ans_2: $p2\n";
