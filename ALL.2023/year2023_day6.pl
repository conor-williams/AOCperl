#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(ceil);

sub ways_to_win {
    my ($time, $record) = @_;

    my $disc = $time * $time - 4 * $record;

    return 0 if $disc <= 0;

    my $sqrt_disc = sqrt($disc);

    my $low  = ($time - $sqrt_disc) / 2;
    my $high = ($time + $sqrt_disc) / 2;

    return int($high) - ceil($low) + 1;
}


sub main {
    my $file = $ARGV[0];

    open(my $fh, "<", $file) or die "Cannot open $file: $!";

    my @lines = grep { /\S/ } map { chomp; $_ } <$fh>;

    close($fh);

    # Remove everything before :
    my ($time_line) = $lines[0] =~ /:(.*)/;
    my ($dist_line) = $lines[1] =~ /:(.*)/;

    # Trim whitespace (Python split() behaviour)
    $time_line =~ s/^\s+|\s+$//g;
    $dist_line =~ s/^\s+|\s+$//g;

    # Correct split: whitespace only, no empty entries
    my @times = split(/\s+/, $time_line);
    my @dists = split(/\s+/, $dist_line);


    # Part 1
    my $p1 = 1;

    for my $i (0 .. $#times) {
        $p1 *= ways_to_win($times[$i], $dists[$i]);
    }


    # Part 2
    my $time = join("", @times);
    my $dist = join("", @dists);

    my $p2 = ways_to_win($time, $dist);


    print "2023 day6: pl_ans_1: $p1\n";
    print "2023 day6: pl_ans_2: $p2\n";
}


main();
