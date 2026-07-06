use strict;
use warnings;

open my $fh, "<", $ARGV[0] or die $!;
chomp(my @ins = <$fh>);

# -------------------------
# python-style slice helper
# -------------------------
sub slice {
    my ($arr, $start, $end) = @_;
    my @out;
    for my $i ($start .. $end - 1) {
        push @out, $arr->[$i];
    }
    return @out;
}

# -------------------------
# apply instructions (1:1 Python logic)
# -------------------------
sub apply {
    my ($pw) = @_;
    my @pw = split //, $pw;

    for my $line (@ins) {
        my @p = split ' ', $line;

        # swap position
        if ($p[0] eq "swap" && $p[1] eq "position") {
            my $x = $p[2];
            my $y = $p[5];

            my $tmp = $pw[$x];
            $pw[$x] = $pw[$y];
            $pw[$y] = $tmp;
        }

        # swap letter
        elsif ($p[0] eq "swap" && $p[1] eq "letter") {
            my $x = $p[2];
            my $y = $p[5];

            for my $i (0 .. $#pw) {
                if ($pw[$i] eq $x) {
                    $pw[$i] = $y;
                }
                elsif ($pw[$i] eq $y) {
                    $pw[$i] = $x;
                }
            }
        }

        # rotate
        elsif ($p[0] eq "rotate") {

            if ($p[1] eq "left" || $p[1] eq "right") {

                my $steps = $p[2] % @pw;

                if ($p[1] eq "right") {
                    $steps = @pw - $steps;
                }

                @pw = (
                    slice(\@pw, $steps, scalar(@pw)),
                    slice(\@pw, 0, $steps)
                );
            }

            # rotate based on position
            else {
                my $x = $p[-1];

                my $i = 0;
                for my $j (0 .. $#pw) {
                    if ($pw[$j] eq $x) {
                        $i = $j;
                        last;
                    }
                }

                my $steps = 1 + $i;
                if ($i >= 4) {
                    $steps++;
                }
                $steps %= @pw;

                my $cut = @pw - $steps;

                @pw = (
                    slice(\@pw, $cut, scalar(@pw)),
                    slice(\@pw, 0, $cut)
                );
            }
        }

        # reverse
        elsif ($p[0] eq "reverse") {
            my $x = $p[2];
            my $y = $p[4];

            my @mid = reverse slice(\@pw, $x, $y + 1);

            my @new;
            for my $i (0 .. $#pw) {
                if ($i < $x) {
                    push @new, $pw[$i];
                }
                elsif ($i >= $x && $i <= $y) {
                    push @new, shift @mid;
                }
                else {
                    push @new, $pw[$i];
                }
            }

            @pw = @new;
        }

        # move
        elsif ($p[0] eq "move") {
            my $x = $p[2];
            my $y = $p[5];

            my $c = splice(@pw, $x, 1);
            splice(@pw, $y, 0, $c);
        }
    }

    return join "", @pw;
}

# -------------------------
# part 1
# -------------------------
my $p1 = apply("abcdefgh");

# -------------------------
# brute force part 2 (unchanged logic)
# -------------------------
sub next_perm {
    my @a = @_;

    my $i = $#a - 1;
    while ($i >= 0 && $a[$i] ge $a[$i + 1]) {
        $i--;
    }
    return () if $i < 0;

    my $j = $#a;
    while ($a[$j] le $a[$i]) {
        $j--;
    }

    @a[$i, $j] = @a[$j, $i];

    my @right = reverse @a[$i + 1 .. $#a];
    @a = (@a[0 .. $i], @right);

    return @a;
}

sub brute {
    my ($target) = @_;

    my @perm = ('a' .. 'h');

    while (1) {
        my $s = join "", @perm;

        return $s if apply($s) eq $target;

        @perm = next_perm(@perm);
        last unless @perm;
    }

    return undef;
}

my $p2 = brute("fbgdceah");

print "2016 day21: pl_ans_1: $p1\n";
print "2016 day21: pl_ans_2: $p2\n";
