use strict;
use warnings;

open my $fh, "<", $ARGV[0] or die $!;

my @changes;

for my $line (<$fh>) {
    chomp $line;
    next if $line eq "";
    push @changes, int($line);
}

# -----------------------------------------
# Part 1
# -----------------------------------------
my $p1 = 0;

for my $n (@changes) {
    $p1 += $n;
}

# -----------------------------------------
# Part 2
# -----------------------------------------
my %seen;

my $freq = 0;
my $i = 0;

$seen{0} = 1;

my $p2;

while (1) {

    $freq += $changes[$i];

    if ($seen{$freq}) {
        $p2 = $freq;
        last;
    }

    $seen{$freq} = 1;

    $i++;

    if ($i >= scalar(@changes)) {
        $i = 0;
    }
}

print "2018 day1: pl_ans_1: $p1\n";
print "2018 day1: pl_ans_2: $p2\n";
