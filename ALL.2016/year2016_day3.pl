use strict;
use warnings;

sub valid {
    my ($a, $b, $c) = @_;
    return ($a + $b > $c && $a + $c > $b && $b + $c > $a);
}

my $path = $ARGV[0];
open my $fh, '<', $path or die $!;

my @rows;
my $p1 = 0;

while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ /^\s*$/;

    my @nums = split ' ', $line;
    push @rows, \@nums;

    $p1++ if valid(@nums);
}

my $p2 = 0;

for (my $i = 0; $i < @rows; $i += 3) {
    my @block = @rows[$i..$i+2];

    for my $col (0..2) {
        my @tri = (
            $block[0][$col],
            $block[1][$col],
            $block[2][$col],
        );

        $p2++ if valid(@tri);
    }
}

print "2016 day3: pl_ans_1: $p1\n";
print "2016 day3: pl_ans_2: $p2\n";
