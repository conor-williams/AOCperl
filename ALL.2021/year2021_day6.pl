use strict;
use warnings;

my $file = $ARGV[0];

sub simulate {
    my ($initial, $days) = @_;

    my @fish = (0) x 9;

    for my $x (@$initial) {
        $fish[$x]++;
    }

    for (1 .. $days) {

        my @new = (0) x 9;

        for my $i (0 .. 8) {

            if ($i == 0) {
                $new[6] += $fish[0];
                $new[8] += $fish[0];
            }
            else {
                $new[$i-1] += $fish[$i];
            }
        }

        @fish = @new;
    }

    my $total = 0;
    $total += $_ for @fish;

    return $total;
}


open my $fh, "<", $file or die "$!\n";

my $line = <$fh>;
chomp $line;

close $fh;

my @initial = split /,/, $line;

my $p1 = simulate(\@initial, 80);
my $p2 = simulate(\@initial, 256);

print "2021 day6: pl_ans_1: $p1\n";
print "2021 day6: pl_ans_2: $p2\n";
