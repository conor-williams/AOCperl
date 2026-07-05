#!/usr/bin/env perl

use strict;
use warnings;

sub parse {
    my ($lines) = @_;

    my %rules;
    my $molecule = "";

    foreach my $line (@$lines) {

        if ($line =~ /=>/) {

            my ($a, $b) = split / => /, $line;
            push @{$rules{$a}}, $b;
        }
        elsif ($line =~ /\S/) {
            $molecule = $line;
        }
    }

    return (\%rules, $molecule);
}

sub part1 {
    my ($rules, $molecule) = @_;

    my %results;

    foreach my $a (keys %$rules) {

        my $alen = length($a);

        for my $i (0 .. length($molecule) - 1) {

            next unless substr($molecule, $i, $alen) eq $a;

            foreach my $b (@{$rules->{$a}}) {

                my $new = substr($molecule, 0, $i)
                        . $b
                        . substr($molecule, $i + $alen);

                $results{$new} = 1;
            }
        }
    }

    return scalar keys %results;
}

sub build_reverse {
    my ($rules) = @_;

    my @rev;

    foreach my $a (keys %$rules) {
        foreach my $b (@{$rules->{$a}}) {
            push @rev, [$b, $a];
        }
    }

    return \@rev;
}

sub part2 {
    my ($rules, $target) = @_;

    my $rev_base = build_reverse($rules);

    my $best = 1e99;

    for (1 .. 5000) {

        my @rev = @$rev_base;
        @rev = sort { rand() <=> rand() } @rev;

        my $mol = $target;
        my $steps = 0;

        while ($mol ne "e") {

            my $changed = 0;

            foreach my $pair (@rev) {

                my ($b, $a) = @$pair;

                if (index($mol, $b) != -1) {

                    $mol =~ s/\Q$b\E/$a/;
                    $steps++;
                    $changed = 1;
                    last;
                }
            }

            last unless $changed;
        }

        if ($mol eq "e") {
            $best = $steps if $steps < $best;
        }
    }

    return ($best == 1e99) ? undef : $best;
}

sub solve {
    my ($lines) = @_;

    my ($rules, $molecule) = parse($lines);

    return (part1($rules, $molecule),
            part2($rules, $molecule));
}

sub main {
    open my $fh, '<', $ARGV[0] or die $!;
    my @lines = map { chomp; $_ } <$fh>;
    close $fh;

    my ($p1, $p2) = solve(\@lines);

    print "2015 day19: pl_ans_1: $p1\n";
    print "2015 day19: pl_ans_2: $p2\n";
}

main();
