use strict;
use warnings;

sub bounds {
    my ($points) = @_;

    my (@xs, @ys);

    foreach my $p (@$points) {
        push @xs, $p->[0];
        push @ys, $p->[1];
    }

    my ($minx, $maxx) = ($xs[0], $xs[0]);
    my ($miny, $maxy) = ($ys[0], $ys[0]);

    foreach (@xs) {
        $minx = $_ if $_ < $minx;
        $maxx = $_ if $_ > $maxx;
    }

    foreach (@ys) {
        $miny = $_ if $_ < $miny;
        $maxy = $_ if $_ > $maxy;
    }

    return ($maxx - $minx) + ($maxy - $miny);
}

sub render {
    my ($points) = @_;

    my (@xs, @ys);
    my %grid;

    foreach my $p (@$points) {
        push @xs, $p->[0];
        push @ys, $p->[1];
        $grid{"$p->[0],$p->[1]"} = 1;
    }

    my ($minx, $maxx) = ($xs[0], $xs[0]);
    my ($miny, $maxy) = ($ys[0], $ys[0]);

    foreach (@xs) {
        $minx = $_ if $_ < $minx;
        $maxx = $_ if $_ > $maxx;
    }

    foreach (@ys) {
        $miny = $_ if $_ < $miny;
        $maxy = $_ if $_ > $maxy;
    }

    for my $y ($miny .. $maxy) {
        my $row = "";
        for my $x ($minx .. $maxx) {
            $row .= exists $grid{"$x,$y"} ? "#" : ".";
        }
        print "$row\n";
    }
}

sub main {

    open(my $fh, "<", $ARGV[0]) or die $!;

    my @points;

    while (<$fh>) {
        chomp;
        next if $_ eq "";

        my @n = /-?\d+/g;
        push @points, [@n];
    }

    close($fh);

    my $prev = bounds(\@points);
    my $t = 0;

    while (1) {

        my @new_points;

        foreach my $p (@points) {
            push @new_points,
              [$p->[0] + $p->[2],
               $p->[1] + $p->[3],
               $p->[2],
               $p->[3]];
        }

        my $b = bounds(\@new_points);

        last if $b > $prev;

        @points = @new_points;
        $prev = $b;
        $t++;
    }

    print "2018 day10: pl_ans_1:\n";
    render(\@points);

    print "2018 day10: pl_ans_2: $t\n";
}

main();
