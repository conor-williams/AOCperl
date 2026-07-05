#!/usr/bin/env perl

use strict;
use warnings;

sub main {

    open my $fh, '<', $ARGV[0] or die "Cannot open $ARGV[0]: $!";

    my @lines;
    while (<$fh>) {
        chomp;
        next unless length;
        push @lines, $_;
    }
    close $fh;

    my %ops;

    foreach my $line (@lines) {
        my ($expr, $out) = split / -> /, $line;
        $ops{$out} = $expr;
    }

    my %memo;

    my $get;
    $get = sub {
        my ($wire) = @_;

        return int($wire) if $wire =~ /^\d+$/;

        return $memo{$wire} if exists $memo{$wire};

        my $expr = $ops{$wire};
        my @parts = split / /, $expr;

        my $val;

        if (@parts == 1) {

            $val = $get->($parts[0]);

        }
        elsif (@parts == 2) {

            # NOT x
            $val = ~$get->($parts[1]) & 0xFFFF;

        }
        else {

            my ($a, $op, $b) = @parts;

            if ($op eq "AND") {
                $val = $get->($a) & $get->($b);
            }
            elsif ($op eq "OR") {
                $val = $get->($a) | $get->($b);
            }
            elsif ($op eq "LSHIFT") {
                $val = ($get->($a) << $b) & 0xFFFF;
            }
            elsif ($op eq "RSHIFT") {
                $val = ($get->($a) >> $b) & 0xFFFF;
            }
            else {
                die "Unknown op: $op";
            }
        }

        $memo{$wire} = $val & 0xFFFF;
        return $memo{$wire};
    };

    # Part 1
    my $p1 = $get->("a");

    # Part 2
    %memo = ();
    $ops{b} = "$p1";

    my $p2 = $get->("a");

    print "2015 day7: pl_ans_1: $p1\n";
    print "2015 day7: pl_ans_2: $p2\n";
}

main();
