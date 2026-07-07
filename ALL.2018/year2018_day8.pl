use strict;
use warnings;

sub parse {
    my ($nums, $i) = @_;

    $i //= 0;

    my $children = $nums->[$i];
    my $meta = $nums->[$i + 1];
    $i += 2;

    my @child_values;
    my $meta_sum = 0;

    for (1 .. $children) {
        my ($ni, $s, $v) = parse($nums, $i);
        $i = $ni;
        $meta_sum += $s;
        push @child_values, $v;
    }

    my @metadata = @$nums[$i .. $i + $meta - 1];
    my $sum = 0;
    $sum += $_ for @metadata;
    $meta_sum += $sum;

    my $value;

    if ($children == 0) {
        $value = $sum;
    }
    else {
        $value = 0;

        foreach my $m (@metadata) {
            if ($m >= 1 && $m <= @child_values) {
                $value += $child_values[$m - 1];
            }
        }
    }

    $i += $meta;

    return ($i, $meta_sum, $value);
}

sub main {

    open(my $fh, "<", $ARGV[0]) or die $!;

    my $line = <$fh>;
    close($fh);

    chomp $line;

    my @nums = split(/\s+/, $line);

    my (undef, $p1, $p2) = parse(\@nums);

    print "2018 day8: pl_ans_1: $p1\n";
    print "2018 day8: pl_ans_2: $p2\n";
}

main();
