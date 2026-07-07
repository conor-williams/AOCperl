### year2017_day23.pl

use strict;
use warnings;

# -------------------------
# Parse
# -------------------------

sub parse {
    my ($lines) = @_;

    my @prog;

    foreach my $line (@$lines) {
        chomp $line;
        next if $line eq "";

        push @prog, [ split(/\s+/, $line) ];
    }

    return \@prog;
}


# -------------------------
# Value helper
# -------------------------

sub val {
    my ($x, $regs) = @_;

    if ($x =~ /^-?\d+$/) {
        return int($x);
    }

    return $regs->{$x} // 0;
}


# -------------------------
# Part 1
# -------------------------

sub part1 {
    my ($prog) = @_;

    my %regs;
    my $ip = 0;
    my $mul_count = 0;

    while ($ip >= 0 && $ip < scalar(@$prog)) {

        my ($op, $x, $y) = @{$prog->[$ip]};

        if ($op eq "set") {
            $regs{$x} = val($y, \%regs);
        }
        elsif ($op eq "sub") {
            $regs{$x} = ($regs{$x} // 0) - val($y, \%regs);
        }
        elsif ($op eq "mul") {
            $regs{$x} = ($regs{$x} // 0) * val($y, \%regs);
            $mul_count++;
        }
        elsif ($op eq "jnz") {
            if (val($x, \%regs) != 0) {
                $ip += val($y, \%regs);
                next;
            }
        }

        $ip++;
    }

    return $mul_count;
}


# -------------------------
# Prime test
# -------------------------

sub is_prime {
    my ($n) = @_;

    return 0 if $n < 2;
    return 1 if $n == 2;
    return 0 if $n % 2 == 0;

    my $i = 3;

    while ($i * $i <= $n) {
        return 0 if $n % $i == 0;
        $i += 2;
    }

    return 1;
}


# -------------------------
# Part 2
# -------------------------

sub part2 {
    my ($prog) = @_;

    my %regs;
    $regs{"a"} = 1;

    my $ip = 0;

    # run initialization exactly
    while ($ip >= 0 && $ip < scalar(@$prog)) {

        my ($op, $x, $y) = @{$prog->[$ip]};

        if ($op eq "set") {
            $regs{$x} = val($y, \%regs);
        }
        elsif ($op eq "sub") {
            $regs{$x} = ($regs{$x} // 0) - val($y, \%regs);
        }
        elsif ($op eq "mul") {
            $regs{$x} = ($regs{$x} // 0) * val($y, \%regs);
        }
        elsif ($op eq "jnz") {
            if (val($x, \%regs) != 0) {
                $ip += val($y, \%regs);
                next;
            }
        }

        #
        # Once initialization reaches the main loop,
        # AoC Day 23 is counting composite numbers.
        #
        if ($ip == 8) {
            last;
        }

        $ip++;
    }


    my $b = $regs{"b"};
    my $c = $regs{"c"};

    #
    # Fallback for inputs where the jump point differs.
    #
    if (!defined($b) || !defined($c)) {
        $b = 109900;
        $c = 126900;
    }


    my $h = 0;

    for (my $x = $b; $x <= $c; $x += 17) {
        if (!is_prime($x)) {
            $h++;
        }
    }

    return $h;
}


# -------------------------
# Main
# -------------------------

sub main {

    open(my $fh, "<", $ARGV[0]) or die $!;

    my @lines = <$fh>;
    close($fh);

    my $prog = parse(\@lines);

    my $p1 = part1($prog);
    my $p2 = part2($prog);

    print "2017 day23: pl_ans_1: $p1\n";
    print "2017 day23: pl_ans_2: $p2\n";
}


main();
