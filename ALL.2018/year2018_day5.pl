use strict;
use warnings;

open my $fh, "<", $ARGV[0] or die $!;
my $polymer = <$fh>;
chomp $polymer;


sub reacts {
    my ($a, $b) = @_;

    return ($a ne $b && lc($a) eq lc($b));
}


sub reduce_polymer {

    my ($polymer) = @_;

    my @stack;

    for my $c (split //, $polymer) {

        if (@stack && reacts($stack[-1], $c)) {
            pop @stack;
        }
        else {
            push @stack, $c;
        }
    }

    return join("", @stack);
}


# -----------------------------------------
# Part 1
# -----------------------------------------

my $reduced = reduce_polymer($polymer);
my $p1 = length($reduced);


# -----------------------------------------
# Part 2
# -----------------------------------------

my %units;

for my $c (split //, lc($polymer)) {
    $units{$c} = 1;
}

my $p2 = 999999999;

for my $u (keys %units) {

    my $test = $polymer;

    $test =~ s/$u//ig;

    my $len = length(reduce_polymer($test));

    if ($len < $p2) {
        $p2 = $len;
    }
}


print "2018 day5: pl_ans_1: $p1\n";
print "2018 day5: pl_ans_2: $p2\n";
