use strict;
use warnings;

open my $fh, "<", $ARGV[0] or die $!;
my @lines = <$fh>;
chomp @lines;
s/\r// for @lines;

my $p1 = 0;
my $p2 = 0;

for my $line (@lines) {

    my @parts = split /\[|\]/, $line;

    my @outs = @parts[ grep { $_ % 2 == 0 } 0..$#parts ];
    my @ins  = @parts[ grep { $_ % 2 == 1 } 0..$#parts ];

    # -------------------------
    # PART 1 (ABBA check)
    # -------------------------
    my $has_abba_out = 0;
    my $has_abba_in  = 0;

    for my $s (@outs) {
        if ($s =~ /(.)(.)\2\1/ && $1 ne $2) {
            $has_abba_out = 1;
        }
    }

    for my $s (@ins) {
        if ($s =~ /(.)(.)\2\1/ && $1 ne $2) {
            $has_abba_in = 1;
        }
    }

    $p1++ if $has_abba_out && !$has_abba_in;

    # -------------------------
    # PART 2 (ABA / BAB)
    # -------------------------
    my %abas;
    my %babs;

    for my $s (@outs) {
        for my $i (0 .. length($s) - 3) {
            my ($a, $b, $c) = split //, substr($s, $i, 3);

            if ($a eq $c && $a ne $b) {
                $abas{"$a$b"} = 1;
            }
        }
    }

    for my $s (@ins) {
        for my $i (0 .. length($s) - 3) {
            my ($a, $b, $c) = split //, substr($s, $i, 3);

            if ($a eq $c && $a ne $b) {
                $babs{"$b$a"} = 1;
            }
        }
    }

    my $ok = 0;
    for my $k (keys %abas) {
        if (exists $babs{$k}) {
            $ok = 1;
            last;
        }
    }

    $p2++ if $ok;
}

print "2016 day7: pl_ans_1: $p1\n";
print "2016 day7: pl_ans_2: $p2\n";
