#!/usr/bin/perl
use strict;
use warnings;

sub parse_move {
    my ($line) = @_;

    my @n = ($line =~ /(\d+)/g);

    return @n;
}


my $file = shift @ARGV or die "usage: perl year2022_day5.pl input.txt\n";

open(my $fh, "<", $file) or die "$!\n";
my @lines = <$fh>;
close($fh);


# ----------------------------
# split drawing / moves
# ----------------------------

my $split = 0;

for my $i (0 .. $#lines) {
    if ($lines[$i] =~ /^\s*$/) {
        $split = $i;
        last;
    }
}

my @drawing = @lines[0 .. $split - 1];
my @moves   = @lines[$split + 1 .. $#lines];

chomp @drawing;
chomp @moves;


# ----------------------------
# build stacks
# ----------------------------

my $ids = $drawing[-1];
my @tmp = split(/\s+/, $ids);
my $num = $tmp[-1];

my @stacks;

for (1 .. $num) {
    push @stacks, [];
}

for (my $r = $#drawing - 1; $r >= 0; $r--) {

    my $line = $drawing[$r];

    for my $i (0 .. $num - 1) {

        my $idx = 1 + $i * 4;

        next if $idx >= length($line);

        my $c = substr($line, $idx, 1);

        if ($c =~ /[A-Za-z]/) {
            push @{$stacks[$i]}, $c;
        }
    }
}


sub solve {

    my ($orig, $moves, $part2) = @_;

    my @s = map { [@$_] } @$orig;

    for my $line (@$moves) {

        next if $line =~ /^\s*$/;

        my ($count,$src,$dst) = parse_move($line);

        $src--;
        $dst--;

        if ($part2) {

            my @temp;

            for (1 .. $count) {
                push @temp, pop @{$s[$src]};
            }

            for (reverse @temp) {
                push @{$s[$dst]}, $_;
            }

        }
        else {

            for (1 .. $count) {
                push @{$s[$dst]}, pop @{$s[$src]};
            }

        }
    }

    my $ans = "";

    for my $stack (@s) {
        $ans .= $stack->[-1] if @$stack;
    }

    return $ans;
}


my $p1 = solve(\@stacks,\@moves,0);
my $p2 = solve(\@stacks,\@moves,1);

print "2022 day5: pl_ans_1: $p1\n";
print "2022 day5: pl_ans_2: $p2\n";
