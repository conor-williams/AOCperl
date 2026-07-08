#!/usr/bin/perl
use strict;
use warnings;

my $file = $ARGV[0] or die "Usage: $0 input.txt\n";

open my $fh, "<", $file or die "$file: $!";
chomp(my @lines = <$fh>);
close $fh;


sub parse_input {
    my (@lines) = @_;

    my ($seed_text) = $lines[0] =~ /:(.*)/;

    my @seeds = map { int($_) }
                grep { $_ ne "" }
                split /\s+/, $seed_text;


    my @blocks;
    my @block;

    for my $line (@lines[2 .. $#lines]) {

        $line =~ s/^\s+|\s+$//g;

        if ($line eq "") {

            if (@block) {
                push @blocks, [ @block ];
                @block = ();
            }

        }
        elsif ($line =~ /map:/) {

            next;

        }
        else {

            my @v = split /\s+/, $line;

            push @block, [
                int($v[0]),
                int($v[1]),
                int($v[2])
            ];
        }
    }

    push @blocks, [ @block ] if @block;

    return (\@seeds, \@blocks);
}



sub apply_layer {
    my ($values, $layer) = @_;

    my @out;

    for my $v (@$values) {

        my $mapped = $v;

        for my $entry (@$layer) {

            my ($dst, $src, $length) = @$entry;

            if ($src <= $v && $v < $src + $length) {

                $mapped = $dst + ($v - $src);
                last;
            }
        }

        push @out, $mapped;
    }

    return @out;
}



sub apply_layer_ranges {
    my ($ranges, $layer) = @_;

    my @result;


    for my $range (@$ranges) {

        my ($start, $end) = @$range;

        my @stack = (
            [$start, $end]
        );


        while (@stack) {

            my $item = pop @stack;

            my ($a, $b) = @$item;

            my $handled = 0;


            for my $entry (@$layer) {

                my ($dst, $src, $length) = @$entry;

                my $s = $src;
                my $e = $src + $length;


                my $left  = $a > $s ? $a : $s;
                my $right = $b < $e ? $b : $e;


                if ($left < $right) {

                    $handled = 1;

                    my $shift = $dst - $src;


                    if ($a < $left) {
                        push @stack, [$a, $left];
                    }


                    if ($right < $b) {
                        push @stack, [$right, $b];
                    }


                    push @result,
                        [
                            $left + $shift,
                            $right + $shift
                        ];

                    last;
                }
            }


            if (!$handled) {

                push @result,
                    [
                        $a,
                        $b
                    ];
            }
        }
    }

    return @result;
}



my ($seeds_ref, $layers_ref) = parse_input(@lines);

my @seeds = @$seeds_ref;
my @layers = @$layers_ref;



# ----------------------
# Part 1
# ----------------------

my @values = @seeds;

for my $layer (@layers) {

    @values = apply_layer(\@values, $layer);

}

my $p1 = $values[0];

for my $v (@values) {
    $p1 = $v if $v < $p1;
}



# ----------------------
# Part 2
# ----------------------

my @ranges;

for (my $i = 0; $i < @seeds; $i += 2) {

    push @ranges,
        [
            $seeds[$i],
            $seeds[$i] + $seeds[$i + 1]
        ];
}



for my $layer (@layers) {

    @ranges = apply_layer_ranges(\@ranges, $layer);

}



my $p2 = $ranges[0][0];

for my $r (@ranges) {

    $p2 = $r->[0] if $r->[0] < $p2;

}



print "2023 day5: pl_ans_1: $p1\n";
print "2023 day5: pl_ans_2: $p2\n";
