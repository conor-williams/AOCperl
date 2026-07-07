use strict;
use warnings;

open my $fh, "<", $ARGV[0] or die $!;

my @lines = <$fh>;
chomp @lines;

# -----------------------------------------
# Part 1
# -----------------------------------------

my $twos = 0;
my $threes = 0;

for my $line (@lines) {

    my %mp;

    for my $c (split //, $line) {

        if (!exists $mp{$c}) {
            $mp{$c} = 0;
        }

        $mp{$c}++;
    }

    my $found2 = 0;
    my $found3 = 0;

    for my $v (values %mp) {

        if ($v == 2) {
            $found2 = 1;
        }

        if ($v == 3) {
            $found3 = 1;
        }
    }

    $twos += $found2;
    $threes += $found3;
}

my $part1 = $twos * $threes;


# -----------------------------------------
# Part 2
# -----------------------------------------

my $ans2 = "";

for (my $i = 0; $i < scalar(@lines); $i++) {

    for (my $j = $i + 1; $j < scalar(@lines); $j++) {

        my $a = $lines[$i];
        my $b = $lines[$j];

        my $diff = 0;
        my $same = "";

        for (my $k = 0; $k < length($a); $k++) {

            if (substr($a,$k,1) ne substr($b,$k,1)) {
                $diff++;
            }
            else {
                $same .= substr($a,$k,1);
            }
        }

        if ($diff == 1) {
            $ans2 = $same;
        }
    }
}

print "2018 day2: pl_ans_1: $part1\n";
print "2018 day2: pl_ans_2: $ans2\n";
