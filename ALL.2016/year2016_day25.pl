use strict;
use warnings;

open my $fh, "<", $ARGV[0] or die $!;
chomp(my @prog = <$fh>);

# -------------------------
# helpers
# -------------------------
sub val {
    my ($x, $r) = @_;
    return ($x =~ /^-?\d+$/) ? $x : $r->{$x};
}

# -------------------------
# run VM
# -------------------------
sub run {
    my ($prog, $r) = @_;

    my $ip = 0;
    my @out;

    while ($ip >= 0 && $ip < @$prog) {
        my @p = split ' ', $prog->[$ip];
        my $op = $p[0];

        if ($op eq "cpy") {
            my $x = $p[1];
            my $y = $p[2];

            if (exists $r->{$y}) {
                $r->{$y} = val($x, $r);
            }

            $ip++;
        }

        elsif ($op eq "inc") {
            $r->{$p[1]}++;
            $ip++;
        }

        elsif ($op eq "dec") {
            $r->{$p[1]}--;
            $ip++;
        }

        elsif ($op eq "jnz") {
            my $x = $p[1];
            my $y = $p[2];

            if (val($x, $r) != 0) {
                $ip += val($y, $r);
            } else {
                $ip++;
            }
        }

        elsif ($op eq "out") {
            push @out, val($p[1], $r);

            # detect repeating pattern like Python solution
            if (@out > 1 && $out[-1] == $out[-2]) {
                return 0;
            }

            if (@out > 20) {
                return 1;
            }

            $ip++;
        }

        else {
            $ip++;
        }
    }

    return 0;
}

# -------------------------
# solve
# -------------------------
sub solve {
    my ($prog) = @_;

    my $a = 0;

    while (1) {
        my %r = (a => $a, b => 0, c => 0, d => 0);

        if (run($prog, \%r)) {
            return $a;
        }

        $a++;
    }
}

# -------------------------
# main
# -------------------------
my $ans = solve(\@prog);

print "2016 day25: pl_ans_1: $ans\n";
