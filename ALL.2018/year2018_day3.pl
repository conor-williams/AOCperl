use strict;
use warnings;
use Data::Dumper;

open my $fh, "<", $ARGV[0] or die $!;

my @claims;
my %fabric;

while (my $line = <$fh>) {

    chomp $line;

    next if $line =~ /^\s*$/;

    my ($cid, $x, $y, $w, $h) =
        $line =~ /#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/;

    push @claims, [$cid, $x, $y, $w, $h];

    for my $i ($x .. $x + $w - 1) {
        for my $j ($y .. $y + $h - 1) {
            $fabric{"$i,$j"}++;
        }
    }
}


# -----------------------------------------
# Part 1
# -----------------------------------------

my $p1 = 0;

for my $v (values %fabric) {
    $p1++ if $v > 1;
}


# -----------------------------------------
# Part 2
# -----------------------------------------

my $p2;

CLAIM:
for my $claim (@claims) {

    my ($cid, $x, $y, $w, $h) = @$claim;

    my $ok = 1;

    for my $i ($x .. $x + $w - 1) {

        for my $j ($y .. $y + $h - 1) {

            if ($fabric{"$i,$j"} != 1) {
                $ok = 0;
                last;
            }
        }

        last unless $ok;
    }

    if ($ok) {
        $p2 = $cid;
        last CLAIM;
    }
}


print "2018 day3: pl_ans_1: $p1\n";
print "2018 day3: pl_ans_2: $p2\n";
