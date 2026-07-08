use strict;
use warnings;


my $file = $ARGV[0];

open my $fh, "<", $file or die "$!\n";

my @lines = grep { /\S/ } map { chomp; $_ } <$fh>;

close $fh;


my $template = $lines[0];

my %rules;


for my $i (1 .. $#lines) {

    my ($a,$b) = split / -> /, $lines[$i];

    $rules{$a} = [
        substr($a,0,1) . $b,
        $b . substr($a,1,1)
    ];
}



my %initial_pairs;

for my $i (0 .. length($template)-2) {

    my $p = substr($template,$i,2);

    $initial_pairs{$p}++;
}



sub run {

    my ($steps) = @_;

    my %pairs = %initial_pairs;


    for (1..$steps) {

        my %new;


        for my $pair (keys %pairs) {

            my $count = $pairs{$pair};

            for my $np (@{$rules{$pair}}) {

                $new{$np} += $count;
            }
        }

        %pairs = %new;
    }


    my %letters;


    for my $pair (keys %pairs) {

        my $count = $pairs{$pair};

        my $c = substr($pair,0,1);

        $letters{$c} += $count;
    }


    # final character counted once

    my $last = substr($template,-1,1);

    $letters{$last}++;


    my $max = 0;
    my $min;


    for my $v (values %letters) {

        $max = $v if $v > $max;

        if (!defined $min || $v < $min) {
            $min = $v;
        }
    }


    return $max-$min;
}



print "2021 day14: pl_ans_1: ", run(10), "\n";
print "2021 day14: pl_ans_2: ", run(40), "\n";
