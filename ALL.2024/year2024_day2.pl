use strict;
use warnings;

sub is_safe {
    my ($report) = @_;

    my @diffs;

    for my $i (0 .. $#$report - 1) {
        push @diffs, $report->[$i+1] - $report->[$i];
    }

    return 1 unless @diffs;

    my $all_inc = 1;
    my $all_dec = 1;

    for my $d (@diffs) {
        $all_inc = 0 if $d <= 0;
        $all_dec = 0 if $d >= 0;
    }

    return 0 unless $all_inc || $all_dec;

    for my $d (@diffs) {
        my $absd = abs($d);
        return 0 if $absd < 1 || $absd > 3;
    }

    return 1;
}


sub is_safe_dampened {
    my ($report) = @_;

    return 1 if is_safe($report);

    for my $i (0 .. $#$report) {
        my @tmp = @$report;
        splice @tmp, $i, 1;

        return 1 if is_safe(\@tmp);
    }

    return 0;
}


my $path = $ARGV[0];

open my $fh, '<', $path or die "$path: $!";

my $p1 = 0;
my $p2 = 0;

while (<$fh>) {
    chomp;
    next if /^\s*$/;

    my @report = map { int($_) } split;

    $p1++ if is_safe(\@report);
    $p2++ if is_safe_dampened(\@report);
}

close $fh;

print "2024 day2: pl_ans_1: $p1\n";
print "2024 day2: pl_ans_2: $p2\n";
