use strict;
use warnings;

open my $fh, "<", $ARGV[0] or die $!;

my @lines;

while (my $line = <$fh>) {
    chomp $line;
    push @lines, $line if $line ne "";
}


# -----------------------------------------
# Parse
# -----------------------------------------

my @records;

for my $line (@lines) {

    my ($y,$mo,$d,$h,$mi,$msg) =
        $line =~ /\[(\d+)-(\d+)-(\d+) (\d+):(\d+)\] (.*)/;

    push @records, [
        int($y),
        int($mo),
        int($d),
        int($h),
        int($mi),
        $msg
    ];
}


@records = sort {
       $a->[0] <=> $b->[0]
    || $a->[1] <=> $b->[1]
    || $a->[2] <=> $b->[2]
    || $a->[3] <=> $b->[3]
    || $a->[4] <=> $b->[4]
} @records;


# -----------------------------------------
# Build sleep map
# -----------------------------------------

my %sleep_map;

my $guard;
my $sleep_start;


for my $r (@records) {

    my ($y,$mo,$d,$h,$mi,$msg) = @$r;


    if ($msg =~ /begins shift/) {

        ($guard) = $msg =~ /#(\d+)/;

    }
    elsif ($msg eq "falls asleep") {

        $sleep_start = $mi;

    }
    elsif ($msg eq "wakes up") {

        for my $m ($sleep_start .. $mi - 1) {
            $sleep_map{$guard}{$m}++;
        }
    }
}


# -----------------------------------------
# Part 1
# -----------------------------------------

my %total_sleep;

for my $g (keys %sleep_map) {

    my $sum = 0;

    for my $v (values %{$sleep_map{$g}}) {
        $sum += $v;
    }

    $total_sleep{$g} = $sum;
}


my ($sleepiest) =
    sort { $total_sleep{$b} <=> $total_sleep{$a} }
    keys %total_sleep;


my ($minute) =
    sort { $sleep_map{$sleepiest}{$b} <=> $sleep_map{$sleepiest}{$a} }
    keys %{$sleep_map{$sleepiest}};


my $p1 = $sleepiest * $minute;


# -----------------------------------------
# Part 2
# -----------------------------------------

my $best_guard;
my $best_minute;
my $best_count = 0;


for my $g (keys %sleep_map) {

    for my $m (keys %{$sleep_map{$g}}) {

        if ($sleep_map{$g}{$m} > $best_count) {

            $best_count = $sleep_map{$g}{$m};
            $best_guard = $g;
            $best_minute = $m;
        }
    }
}


my $p2 = $best_guard * $best_minute;


print "2018 day4: pl_ans_1: $p1\n";
print "2018 day4: pl_ans_2: $p2\n";
