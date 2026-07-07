use strict;
use warnings;

sub parse {
    my ($text) = @_;

    my @lines = grep { $_ ne "" } map { s/^\s+|\s+$//gr } split /\n/, $text;

    my ($state) = $lines[0] =~ /: (.*)/;

    my %rules;

    for my $line (@lines[1 .. $#lines]) {
        my ($a, $b) = split / => /, $line;
        $rules{$a} = $b;
    }

    return ($state, \%rules);
}

sub step {
    my ($plants, $rules) = @_;

    my %new_plants;

    my @vals = keys %$plants;
    my $lo = $vals[0];
    my $hi = $vals[0];

    for (@vals) {
        $lo = $_ if $_ < $lo;
        $hi = $_ if $_ > $hi;
    }

    for (my $i = $lo - 3; $i <= $hi + 3; $i++) {

        my $pat = "";

        for (my $j = $i - 2; $j <= $i + 2; $j++) {
            $pat .= exists $plants->{$j} ? "#" : ".";
        }

        if (($rules->{$pat} // ".") eq "#") {
            $new_plants{$i} = 1;
        }
    }

    return \%new_plants;
}

sub score {
    my ($plants) = @_;

    my $sum = 0;
    $sum += $_ for keys %$plants;

    return $sum;
}

sub part1 {
    my ($state, $rules) = @_;

    my %plants;

    my @chars = split //, $state;
    for (my $i = 0; $i < @chars; $i++) {
        if ($chars[$i] eq "#") {
            $plants{$i} = 1;
        }
    }

    for (1 .. 20) {
        my $next = step(\%plants, $rules);
        %plants = %$next;
    }

    return score(\%plants);
}

sub part2 {
    my ($state, $rules) = @_;

    my %plants;

    my @chars = split //, $state;
    for (my $i = 0; $i < @chars; $i++) {
        if ($chars[$i] eq "#") {
            $plants{$i} = 1;
        }
    }

    my $prev = score(\%plants);
    my $prev_diff;

    my $target = 50_000_000_000;

    for (my $gen = 1; $gen < 5000; $gen++) {

        my $next = step(\%plants, $rules);
        %plants = %$next;

        my $s = score(\%plants);
        my $diff = $s - $prev;

        if (defined($prev_diff) && $diff == $prev_diff) {
            my $remaining = $target - $gen;
            return $s + $remaining * $diff;
        }

        $prev = $s;
        $prev_diff = $diff;
    }

    return score(\%plants);
}

sub solve {
    my ($text) = @_;

    my ($state, $rules) = parse($text);

    return (part1($state, $rules), part2($state, $rules));
}

my $text = do {
    local $/;
    open my $fh, "<", $ARGV[0] or die $!;
    <$fh>;
};

my ($p1, $p2) = solve($text);

print "2018 day12: pl_ans_1: $p1\n";
print "2018 day12: pl_ans_2: $p2\n";
