use strict;
use warnings;

my $file = $ARGV[0];

open my $fh, "<", $file or die "$!\n";
my $line = <$fh>;
close $fh;

chomp $line;

my @crabs = split /,/, $line;

my $lo = $crabs[0];
my $hi = $crabs[0];

for my $c (@crabs) {
    $lo = $c if $c < $lo;
    $hi = $c if $c > $hi;
}

sub cost_linear {
    my ($pos, $crabs) = @_;

    my $sum = 0;

    for my $c (@$crabs) {
        $sum += abs($c - $pos);
    }

    return $sum;
}


sub cost_triangular {
    my ($pos, $crabs) = @_;

    my $sum = 0;

    for my $c (@$crabs) {

        my $d = abs($c - $pos);

        $sum += ($d * ($d + 1)) / 2;
    }

    return $sum;
}


my $p1;

for my $p ($lo .. $hi) {

    my $v = cost_linear($p, \@crabs);

    if (!defined($p1) || $v < $p1) {
        $p1 = $v;
    }
}


my $p2;

for my $p ($lo .. $hi) {

    my $v = cost_triangular($p, \@crabs);

    if (!defined($p2) || $v < $p2) {
        $p2 = $v;
    }
}


print "2021 day7: pl_ans_1: $p1\n";
print "2021 day7: pl_ans_2: $p2\n";
