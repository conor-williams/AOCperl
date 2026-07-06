use strict;
use warnings;

open my $fh, "<", $ARGV[0] or die $!;
my @prog = <$fh>;
chomp @prog;

sub val {
    my ($x, $r) = @_;
    return ($x =~ /^-?\d+$/) ? $x : $r->{$x};
}

sub run {
    my ($prog, $c_init) = @_;

    my %r = (
        a => 0,
        b => 0,
        c => $c_init,
        d => 0
    );

    my $ip = 0;

    while ($ip >= 0 && $ip < @{$prog}) {

        my @p = split ' ', $prog->[$ip];
        my $op = $p[0];

        if ($op eq "cpy") {
            my ($x, $y) = @p[1,2];

            # CRITICAL FIX: must check register
            if (exists $r{$y}) {
                $r{$y} = val($x, \%r);
            }

            $ip++;
        }

        elsif ($op eq "inc") {
            $r{$p[1]}++ if exists $r{$p[1]};
            $ip++;
        }

        elsif ($op eq "dec") {
            $r{$p[1]}-- if exists $r{$p[1]};
            $ip++;
        }

        elsif ($op eq "jnz") {
            my ($x, $y) = @p[1,2];

            if (val($x, \%r) != 0) {
                $ip += val($y, \%r);
            } else {
                $ip++;
            }
        }

        else {
            $ip++;
        }
    }

    return $r{a};
}

my $p1 = run(\@prog, 0);
my $p2 = run(\@prog, 1);

print "2016 day12: pl_ans_1: $p1\n";
print "2016 day12: pl_ans_2: $p2\n";
