use strict;
use warnings;

my $file = $ARGV[0];

sub sign {
    my ($x) = @_;
    return ($x > 0) - ($x < 0);
}

open my $fh, "<", $file or die "$!\n";

my @lines;

while (<$fh>) {
    chomp;
    next unless /\S/;

    my ($a, $b) = split / -> /;

    my ($x1, $y1) = split /,/, $a;
    my ($x2, $y2) = split /,/, $b;

    push @lines, [$x1, $y1, $x2, $y2];
}

close $fh;

my %c1;
my %c2;

for my $line (@lines) {

    my ($x1, $y1, $x2, $y2) = @$line;

    my $dx = sign($x2 - $x1);
    my $dy = sign($y2 - $y1);

    my ($x, $y) = ($x1, $y1);

    while (1) {

        my $key = "$x,$y";

        $c2{$key}++;

        if ($x1 == $x2 || $y1 == $y2) {
            $c1{$key}++;
        }

        last if ($x == $x2 && $y == $y2);

        $x += $dx;
        $y += $dy;
    }
}

my $p1 = 0;
for my $v (values %c1) {
    $p1++ if $v >= 2;
}

my $p2 = 0;
for my $v (values %c2) {
    $p2++ if $v >= 2;
}

print "2021 day5: pl_ans_1: $p1\n";
print "2021 day5: pl_ans_2: $p2\n";
