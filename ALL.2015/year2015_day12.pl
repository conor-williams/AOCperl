#!/usr/bin/env perl

use strict;
use warnings;
use JSON::PP;

sub sum_all {
    my ($obj) = @_;

    if (!ref($obj)) {
        return ($obj =~ /^-?\d+$/) ? $obj : 0;
    }

    if (ref($obj) eq 'ARRAY') {
        my $sum = 0;
        $sum += sum_all($_) for @$obj;
        return $sum;
    }

    if (ref($obj) eq 'HASH') {
        my $sum = 0;
        $sum += sum_all($_) for values %$obj;
        return $sum;
    }

    return 0;
}

sub sum_no_red {
    my ($obj) = @_;

    if (!ref($obj)) {
        return ($obj =~ /^-?\d+$/) ? $obj : 0;
    }

    if (ref($obj) eq 'ARRAY') {
        my $sum = 0;
        $sum += sum_no_red($_) for @$obj;
        return $sum;
    }

    if (ref($obj) eq 'HASH') {

        for my $v (values %$obj) {
            if (!ref($v) && $v eq "red") {
                return 0;
            }
        }

        my $sum = 0;
        $sum += sum_no_red($_) for values %$obj;
        return $sum;
    }

    return 0;
}

sub main {

    open my $fh, '<', $ARGV[0] or die "Cannot open $ARGV[0]: $!";
    local $/;
    my $json_text = <$fh>;
    close $fh;

    my $data = decode_json($json_text);

    my $p1 = sum_all($data);
    my $p2 = sum_no_red($data);

    print "2015 day12: pl_ans_1: $p1\n";
    print "2015 day12: pl_ans_2: $p2\n";
}

main();
