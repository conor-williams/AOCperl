use strict;
use warnings;

my $file = $ARGV[0];

open my $fh, "<", $file or die "$!\n";

my @lines = grep { /\S/ } map { chomp; $_ } <$fh>;

close $fh;


my %pairs = (
    "(" => ")",
    "[" => "]",
    "{" => "}",
    "<" => ">"
);

my %score_p1 = (
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137
);

my %score_p2 = (
    ")" => 1,
    "]" => 2,
    "}" => 3,
    ">" => 4
);


my $p1 = 0;
my @completions;


for my $line (@lines) {

    my @stack;
    my $corrupt = 0;

    for my $c (split //, $line) {

        if (exists $pairs{$c}) {

            push @stack, $c;

        }
        else {

            my $open = pop @stack;

            if ($pairs{$open} ne $c) {

                $p1 += $score_p1{$c};
                $corrupt = 1;
                last;
            }
        }
    }


    if (!$corrupt) {

        my $score = 0;

        while (@stack) {

            my $c = $pairs{pop @stack};

            $score = $score * 5 + $score_p2{$c};
        }

        push @completions, $score;
    }
}


@completions = sort { $a <=> $b } @completions;

my $p2 = $completions[int(@completions / 2)];


print "2021 day10: pl_ans_1: $p1\n";
print "2021 day10: pl_ans_2: $p2\n";
