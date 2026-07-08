#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(min);

my %D = (
    "|" => [[-1,0],[1,0]],
    "-" => [[0,-1],[0,1]],
    "L" => [[-1,0],[0,1]],
    "J" => [[-1,0],[0,-1]],
    "7" => [[1,0],[0,-1]],
    "F" => [[1,0],[0,1]],
    "." => [],
);

sub contains_dir {
    my ($list, $dr, $dc) = @_;

    for my $d (@$list) {
        return 1 if $d->[0] == $dr && $d->[1] == $dc;
    }

    return 0;
}

sub main {
    my $path = $ARGV[0];

    open my $fh, "<", $path or die "$path: $!";

    my @G = <$fh>;
    chomp @G;

    close $fh;

    my $R = scalar @G;
    my $C = length($G[0]);

    my ($sr, $sc);

    for my $r (0 .. $R - 1) {
        if (index($G[$r], "S") >= 0) {
            $sr = $r;
            $sc = index($G[$r], "S");
            last;
        }
    }

    my @sd;

    for my $d ([-1,0],[1,0],[0,-1],[0,1]) {
        my ($dr,$dc)=@$d;

        my $nr = $sr + $dr;
        my $nc = $sc + $dc;

        next if $nr < 0 || $nr >= $R || $nc < 0 || $nc >= $C;

        my $ch = substr($G[$nr], $nc, 1);

        if (contains_dir($D{$ch}, -$dr, -$dc)) {
            push @sd, [$dr,$dc];
        }
    }

    my %loop;
    my @queue = ([$sr,$sc]);

    $loop{"$sr,$sc"} = 1;

    my $head = 0;

    while ($head < @queue) {
        my ($r,$c) = @{ $queue[$head++] };

        my $ch = substr($G[$r], $c, 1);

        my $dirs = ($r == $sr && $c == $sc) ? \@sd : $D{$ch};

        for my $d (@$dirs) {
            my ($dr,$dc)=@$d;

            my $nr = $r + $dr;
            my $nc = $c + $dc;

            next if $nr < 0 || $nr >= $R || $nc < 0 || $nc >= $C;

            next if exists $loop{"$nr,$nc"};

            my $nch = substr($G[$nr], $nc, 1);
            my $nd = ($nr == $sr && $nc == $sc) ? \@sd : $D{$nch};

            if (contains_dir($nd, -$dr, -$dc)) {
                $loop{"$nr,$nc"} = 1;
                push @queue, [$nr,$nc];
            }
        }
    }

    print "2023 day10: pl_ans_1: ", int(keys(%loop) / 2), "\n";

    my $A = 0;

    for my $r (0 .. $R - 1) {
        my $inside = 0;

        for my $c (0 .. $C - 1) {

            if (exists $loop{"$r,$c"}) {

                my $ch = substr($G[$r], $c, 1);

                if ($r == $sr && $c == $sc) {
                    for my $k (keys %D) {
                        next unless $k ne ".";
                        my @a = sort map { join(",", @$_) } @{ $D{$k} };
                        my @b = sort map { join(",", @$_) } @sd;

                        if ("@a" eq "@b") {
                            $ch = $k;
                            last;
                        }
                    }
                }

                if ($ch eq "|" || $ch eq "L" || $ch eq "J") {
                    $inside = !$inside;
                }
            }
            else {
                $A++ if $inside;
            }
        }
    }

    print "2023 day10: pl_ans_2: $A\n";
}

main();
