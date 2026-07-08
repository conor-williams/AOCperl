use strict;
use warnings;


my $file = $ARGV[0];

open my $fh, "<", $file or die "$!\n";

my @grid;

while (<$fh>) {

    chomp;

    next unless /\S/;

    push @grid, [ map { int($_) } split // ];
}

close $fh;


sub step {

    my ($grid) = @_;

    my $h = scalar @$grid;
    my $w = scalar @{$grid->[0]};

    my %flashed;
    my @queue;


    # increase energy

    for my $y (0 .. $h-1) {

        for my $x (0 .. $w-1) {

            $grid->[$y][$x]++;

            if ($grid->[$y][$x] > 9) {

                push @queue, [$x,$y];
            }
        }
    }


    # flash propagation

    while (@queue) {

        my $cur = shift @queue;

        my ($x,$y) = @$cur;

        next if exists $flashed{"$x,$y"};

        $flashed{"$x,$y"} = 1;


        for my $dx (-1..1) {

            for my $dy (-1..1) {

                next if $dx == 0 && $dy == 0;

                my $nx = $x + $dx;
                my $ny = $y + $dy;

                next if $nx < 0 || $nx >= $w;
                next if $ny < 0 || $ny >= $h;

                next if exists $flashed{"$nx,$ny"};


                $grid->[$ny][$nx]++;


                if ($grid->[$ny][$nx] > 9) {

                    push @queue, [$nx,$ny];
                }
            }
        }
    }


    # reset

    for my $key (keys %flashed) {

        my ($x,$y) = split /,/, $key;

        $grid->[$y][$x] = 0;
    }


    return scalar keys %flashed;
}



# Part 1

my @g1 = map { [ @$_ ] } @grid;

my $p1 = 0;

for (1..100) {

    $p1 += step(\@g1);
}



# Part 2

my @g2 = map { [ @$_ ] } @grid;

my $total = scalar(@g2) * scalar(@{$g2[0]});

my $p2 = 0;

for (my $i = 1; ; $i++) {

    if (step(\@g2) == $total) {

        $p2 = $i;
        last;
    }
}


print "2021 day11: pl_ans_1: $p1\n";
print "2021 day11: pl_ans_2: $p2\n";
