use strict;
use warnings;

use Math::BigInt;

open my $fh, "<", $ARGV[0] or die $!;
chomp(my @program = <$fh>);

# ----------------------------
# helper: get value
# ----------------------------
sub get_val {
    my ($x, $regs) = @_;
    return ($x =~ /^-?\d+$/) ? $x : $regs->{$x};
}

# ----------------------------
# toggle instruction
# ----------------------------
sub toggle {
    my ($instr) = @_;
    my @p = split ' ', $instr;

    if (@p == 2) {
        return ($p[0] eq "inc")
            ? "dec $p[1]"
            : "inc $p[1]";
    }

    if ($p[0] eq "jnz") {
        return "cpy $p[1] $p[2]";
    }

    if ($p[0] eq "cpy") {
        return "jnz $p[1] $p[2]";
    }

    return $instr;
}

# ----------------------------
# interpreter (exact Python behavior)
# ----------------------------
sub run_program {
    my ($program_ref, $regs) = @_;
    my @prog = @$program_ref;

    my $i = 0;

    while ($i >= 0 && $i < @prog) {

        my @p = split ' ', $prog[$i];
        my $op = $p[0];

        if ($op eq "cpy") {
            my ($x, $y) = @p[1,2];
            if (exists $regs->{$y}) {
                $regs->{$y} = get_val($x, $regs);
            }
            $i++;
        }

        elsif ($op eq "inc") {
            $regs->{$p[1]}++;
            $i++;
        }

        elsif ($op eq "dec") {
            $regs->{$p[1]}--;
            $i++;
        }

        elsif ($op eq "jnz") {
            my ($x, $y) = @p[1,2];
            if (get_val($x, $regs) != 0) {
                $i += get_val($y, $regs);
            } else {
                $i++;
            }
        }

        elsif ($op eq "tgl") {
            my $x = get_val($p[1], $regs);
            my $target = $i + $x;

            if ($target >= 0 && $target < @prog) {
                $prog[$target] = toggle($prog[$target]);
            }

            $i++;
        }

        else {
            $i++;
        }
    }

    return $regs;
}

# ----------------------------
# PART 1
# ----------------------------
my %regs1 = (
    a => 7,
    b => 0,
    c => 0,
    d => 0
);

run_program(\@program, \%regs1);

print "2016 day23: pl_ans_1: $regs1{a}\n";

# ----------------------------
# PART 2 (Python-equivalent optimization)
# ----------------------------
my $x = (split ' ', $program[-7])[1];
my $y = (split ' ', $program[-6])[1];

sub factorial {
    my $n = shift;
    my $r = Math::BigInt->new(1);
    $r *= $_ for 2..$n;
    return $r;
}

my $p2 = factorial(12) + ($x * $y);

print "2016 day23: pl_ans_2: $p2\n";
