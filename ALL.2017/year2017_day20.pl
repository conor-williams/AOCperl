use strict;
use warnings;

sub parse {
    my (@lines) = @_;
    my @particles;

    for my $line (@lines) {
        my @nums = ($line =~ /-?\d+/g);

        my @p = @nums[0..2];
        my @v = @nums[3..5];
        my @a = @nums[6..8];

        push @particles, [\@p, \@v, \@a];
    }

    return \@particles;
}


sub manhattan {
    my ($v) = @_;

    my $sum = 0;
    for my $x (@$v) {
        $sum += abs($x);
    }

    return $sum;
}


sub part1 {
    my ($particles) = @_;

    my $best = 0;

    for my $i (0 .. $#$particles) {
        my ($p, $v, $a) = @{$particles->[$i]};

        my $key = [
            manhattan($a),
            manhattan($v),
            manhattan($p)
        ];

        if ($i == 0) {
            $best = $i;
        }
        else {
            my ($bp, $bv, $ba) = @{$particles->[$best]};

            my $best_key = [
                manhattan($ba),
                manhattan($bv),
                manhattan($bp)
            ];

            if ($key->[0] < $best_key->[0]
                || ($key->[0] == $best_key->[0] && $key->[1] < $best_key->[1])
                || ($key->[0] == $best_key->[0] && $key->[1] == $best_key->[1] && $key->[2] < $best_key->[2])) {
                $best = $i;
            }
        }
    }

    return $best;
}


sub step {
    my ($particles) = @_;

    my %pos_map;

    for my $i (0 .. $#$particles) {
        my ($p, $v, $a) = @{$particles->[$i]};

        for my $j (0..2) {
            $v->[$j] += $a->[$j];
            $p->[$j] += $v->[$j];
        }

        my $key = join(",", @$p);

        push @{$pos_map{$key}}, $i;
    }

    my %remove;

    for my $key (keys %pos_map) {
        if (@{$pos_map{$key}} > 1) {
            for my $i (@{$pos_map{$key}}) {
                $remove{$i} = 1;
            }
        }
    }

    my @new;

    for my $i (0 .. $#$particles) {
        push @new, $particles->[$i] unless exists $remove{$i};
    }

    return \@new;
}


sub part2 {
    my ($particles) = @_;

    my @copy;

    for my $p (@$particles) {
        push @copy, [
            [ @{$p->[0]} ],
            [ @{$p->[1]} ],
            [ @{$p->[2]} ]
        ];
    }

    my $last = scalar(@copy);
    my $stable = 0;

    for (1..200) {
        my $new = step(\@copy);
        @copy = @$new;

        if (@copy == $last) {
            $stable++;
        }
        else {
            $stable = 0;
        }

        $last = scalar(@copy);

        last if $stable > 20;
    }

    return scalar(@copy);
}


sub main {
    open(my $fh, "<", $ARGV[0]) or die $!;

    my @lines = <$fh>;
    chomp @lines;

    my $particles = parse(@lines);

    my $p1 = part1($particles);
    my $p2 = part2($particles);

    print "2017 day20: pl_ans_1: $p1\n";
    print "2017 day20: pl_ans_2: $p2\n";
}

main();
