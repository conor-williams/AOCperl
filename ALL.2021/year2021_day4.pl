#!/usr/bin/perl
use strict;
use warnings;


my $path = $ARGV[0];

open my $fh, "<", $path or die "$path: $!";

my @lines = <$fh>;

close $fh;


@lines = map {
    chomp;
    s/^\s+//;
    s/\s+$//;
    $_
} @lines;



my @nums = split /,/, $lines[0];


my @boards;

my $i = 2;

while ($i < scalar(@lines)) {

    if ($lines[$i] !~ /\S/) {
        $i++;
        next;
    }

    my @board;

    for (1..5) {

        my @row = split /\s+/, $lines[$i];
        push @board, \@row;

        $i++;
    }

    push @boards, \@board;
}



sub check_win {

    my ($marked) = @_;

    # rows

    for my $r (@$marked) {

        return 1 if $r->[0] &&
                    $r->[1] &&
                    $r->[2] &&
                    $r->[3] &&
                    $r->[4];
    }


    # columns

    for my $c (0..4) {

        return 1 if $marked->[0][$c] &&
                    $marked->[1][$c] &&
                    $marked->[2][$c] &&
                    $marked->[3][$c] &&
                    $marked->[4][$c];
    }


    return 0;
}



sub score {

    my ($board, $marked, $last) = @_;

    my $sum = 0;

    for my $r (0..4) {
        for my $c (0..4) {

            if (!$marked->[$r][$c]) {
                $sum += $board->[$r][$c];
            }

        }
    }

    return $sum * $last;
}



my @marked;

for my $board (@boards) {

    my @m;

    for (0..4) {
        push @m, [ (0,0,0,0,0) ];
    }

    push @marked, \@m;
}


my %won;

my $first_score;
my $last_score;


for my $n (@nums) {

    for my $bi (0..$#boards) {

        next if exists $won{$bi};


        for my $r (0..4) {
            for my $c (0..4) {

                if ($boards[$bi][$r][$c] == $n) {
                    $marked[$bi][$r][$c] = 1;
                }

            }
        }


        if (check_win($marked[$bi])) {

            $won{$bi} = 1;

            my $sc = score(
                $boards[$bi],
                $marked[$bi],
                $n
            );


            if (!defined $first_score) {
                $first_score = $sc;
            }

            $last_score = $sc;
        }
    }
}


print "2021 day4: pl_ans_1: $first_score\n";
print "2021 day4: pl_ans_2: $last_score\n";
