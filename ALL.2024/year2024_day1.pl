use strict;
use warnings;

my $path = $ARGV[0];

my @left;
my @right;

open my $fh, '<', $path or die "$path: $!";

while (<$fh>) {
    chomp;
    next if /^\s*$/;

    my ($a, $b) = split;
    push @left,  int($a);
    push @right, int($b);
}

close $fh;

# Part 1
@left  = sort { $a <=> $b } @left;
@right = sort { $a <=> $b } @right;

my $p1 = 0;

for my $i (0 .. $#left) {
    $p1 += abs($left[$i] - $right[$i]);
}

# Part 2
my %freq;

for my $r (@right) {
    $freq{$r}++;
}

my $p2 = 0;

for my $x (@left) {
    $p2 += $x * ($freq{$x} // 0);
}

print "2024 day1: pl_ans_1: $p1\n";
print "2024 day1: pl_ans_2: $p2\n";
