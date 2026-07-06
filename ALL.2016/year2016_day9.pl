use strict;
use warnings;

sub decompressed_length {
    my ($s, $part2) = @_;

    my $i = 0;
    my $total = 0;

    while ($i < length($s)) {
        if (substr($s, $i, 1) ne "(") {
            $total++;
            $i++;
        } else {
            my $j = index($s, ")", $i);
            my ($a, $b) = split /x/, substr($s, $i+1, $j-$i-1);

            my $segment = substr($s, $j+1, $a);

            if ($part2) {
                $total += decompressed_length($segment, 1) * $b;
            } else {
                $total += $a * $b;
            }

            $i = $j + 1 + $a;
        }
    }

    return $total;
}

my $path = $ARGV[0];
open my $fh, '<', $path or die $!;

my $s = do { local $/; <$fh> };
chomp $s;

my $p1 = decompressed_length($s, 0);
my $p2 = decompressed_length($s, 1);

print "2016 day9: pl_ans_1: $p1\n";
print "2016 day9: pl_ans_2: $p2\n";
