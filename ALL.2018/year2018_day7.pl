use strict;
use warnings;
use List::Util qw(min);

sub main {

    open(my $fh, "<", $ARGV[0]) or die $!;

    my @lines;
    while (<$fh>) {
        chomp;
        next if $_ eq "";
        push @lines, $_;
    }
    close($fh);

    my %prereq;
    my %steps;

    foreach my $line (@lines) {
        $line =~ /Step (\w) must be finished before step (\w) can begin/;
        my ($a, $b) = ($1, $2);

        $prereq{$b}{$a} = 1;
        $steps{$a} = 1;
        $steps{$b} = 1;
    }

    # -------------------------
    # Part 1
    # -------------------------

    my %done;
    my @order;

    while (@order < keys(%steps)) {

        my @available;

        foreach my $s (sort keys %steps) {

            next if exists $done{$s};

            my $ok = 1;

            if (exists $prereq{$s}) {
                foreach my $p (keys %{$prereq{$s}}) {
                    if (!exists $done{$p}) {
                        $ok = 0;
                        last;
                    }
                }
            }

            push @available, $s if $ok;
        }

        my $next = $available[0];
        push @order, $next;
        $done{$next} = 1;
    }

    my $p1 = join("", @order);

    # -------------------------
    # Part 2
    # -------------------------

    %done = ();

    my @workers = (0, 0, 0, 0, 0);
    my @tasks = ("", "", "", "", "");

    my $time = 0;

    while (scalar(keys %done) < scalar(keys %steps)) {

        my @available;

        foreach my $s (sort keys %steps) {

            next if exists $done{$s};

            my $already = 0;
            foreach my $t (@tasks) {
                if ($t eq $s) {
                    $already = 1;
                    last;
                }
            }
            next if $already;

            my $ok = 1;

            if (exists $prereq{$s}) {
                foreach my $p (keys %{$prereq{$s}}) {
                    if (!exists $done{$p}) {
                        $ok = 0;
                        last;
                    }
                }
            }

            push @available, $s if $ok;
        }

        foreach my $i (0 .. 4) {

            next unless $workers[$i] == 0;

            if (@available) {
                my $s = shift @available;
                $tasks[$i] = $s;
                $workers[$i] = 60 + ord($s) - ord("A") + 1;
            }
        }

        my @active = grep { $_ > 0 } @workers;
        my $min_time = @active ? min(@active) : 1;

        $time += $min_time;

        foreach my $i (0 .. 4) {
            if ($workers[$i] > 0) {
                $workers[$i] -= $min_time;

                if ($workers[$i] == 0 && $tasks[$i] ne "") {
                    $done{$tasks[$i]} = 1;
                    $tasks[$i] = "";
                }
            }
        }
    }

    my $p2 = $time;

    print "2018 day7: pl_ans_1: $p1\n";
    print "2018 day7: pl_ans_2: $p2\n";
}

main();
