use strict;
use warnings;


sub blink {
    my ($stones) = @_;

    my %out;


    for my $s (keys %$stones) {

        my $count = $stones->{$s};


        if ($s == 0) {

            $out{1} += $count;

        }
        else {

            my $t = "$s";

            if (length($t) % 2 == 0) {

                my $mid = length($t) / 2;

                my $a = substr($t, 0, $mid);
                my $b = substr($t, $mid);

                $out{int($a)} += $count;
                $out{int($b)} += $count;

            }
            else {

                $out{$s * 2024} += $count;
            }
        }
    }


    return \%out;
}


sub solve {
    my ($start, $steps) = @_;

    my %stones;

    $stones{$_}++ for @$start;


    for (1 .. $steps) {
        my $next = blink(\%stones);
        %stones = %$next;
    }


    my $total = 0;

    $total += $_ for values %stones;

    return $total;
}


my $path = $ARGV[0];

open my $fh, '<', $path or die "$path: $!";

local $/;
my $data = <$fh>;

close $fh;


my @start = map { int($_) } split /\s+/, $data;


my $p1 = solve(\@start, 25);
my $p2 = solve(\@start, 75);


print "2024 day11: pl_ans_1: $p1\n";
print "2024 day11: pl_ans_2: $p2\n";
