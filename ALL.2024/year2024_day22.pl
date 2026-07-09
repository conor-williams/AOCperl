use strict;
use warnings;
use List::Util qw(max);


my $DAY = 22;


# ---------------- PRNG ----------------

sub step {

    my ($x)=@_;

    $x ^= (($x << 6) & 0xFFFFFF);
    $x ^= ($x >> 5);
    $x ^= (($x << 11) & 0xFFFFFF);

    return $x & 0xFFFFFF;
}



# ---------------- PART 1 ----------------

sub part1 {

    my ($seeds)=@_;

    my $total=0;


    for my $s (@$seeds) {

        my $x=$s;

        for (1..2000) {
            $x=step($x);
        }

        $total += $x;
    }


    return $total;
}



# ---------------- PART 2 ----------------

sub part2 {

    my ($seeds)=@_;


    my %score_map;


    for my $s (@$seeds) {

        my $x=$s;

        my @prices;


        for (1..2000) {

            $x=step($x);

            push @prices, $x % 10;
        }


        my @deltas;


        for my $i (1..$#prices) {

            push @deltas,
                $prices[$i]-$prices[$i-1];
        }


        my %local_seen;


        for my $i (0..$#deltas-3) {

            my $seq =
                join(",",
                    $deltas[$i],
                    $deltas[$i+1],
                    $deltas[$i+2],
                    $deltas[$i+3]
                );


            next if exists $local_seen{$seq};


            $local_seen{$seq}=1;


            $score_map{$seq} += $prices[$i+4];
        }
    }


    return max(values %score_map);
}



# ---------------- PARSE ----------------

sub parse {

    my ($data)=@_;

    return [
        map { int($_) }
        grep { /\S/ }
        split /\s+/, $data
    ];
}



# ---------------- MAIN ----------------

my $path=$ARGV[0];

open my $fh,'<',$path or die "$path: $!";

local $/;

my $data=<$fh>;

close $fh;


my $seeds=parse($data);


my $ans1=part1($seeds);
my $ans2=part2($seeds);


print "2024 day$DAY: pl_ans_1: $ans1\n";
print "2024 day$DAY: pl_ans_2: $ans2\n";
