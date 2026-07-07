use strict;
use warnings;

my $file = $ARGV[0];

open(my $fh, "<", $file) or die "Cannot open $file";

my @program;

while (<$fh>) {
    chomp;
    next if $_ eq "";

    push @program, [split(/\s+/, $_)];
}

close($fh);

sub val {
    my ($x, $regs) = @_;


    return $x =~ /^-?\d+$/ ? int($x) : ($regs->{$x} // 0);
}


sub run_part1 {

    my ($program) = @_;

    my %regs = map { $_ => 0 } ('a'..'z');

    my $last_sound = 0;
    my $i = 0;


    while ($i >= 0 && $i < scalar(@$program)) {

        my ($op, @args) = @{$program->[$i]};


        if ($op eq "snd") {

            $last_sound = val($args[0], \%regs);

        }
        elsif ($op eq "set") {

            $regs{$args[0]} = val($args[1], \%regs);

        }
        elsif ($op eq "add") {

            $regs{$args[0]} += val($args[1], \%regs);

        }
        elsif ($op eq "mul") {

            $regs{$args[0]} *= val($args[1], \%regs);

        }
        elsif ($op eq "mod") {

            $regs{$args[0]} %= val($args[1], \%regs);

        }
        elsif ($op eq "rcv") {

            if (val($args[0], \%regs) != 0) {
                return $last_sound;
            }

        }
        elsif ($op eq "jgz") {

            if (val($args[0], \%regs) > 0) {

                $i += val($args[1], \%regs);
                next;
            }
        }

        $i++;
    }

    return undef;
}



sub run_part2 {

    my ($program) = @_;

    my @regs;

    $regs[0] = {};
    $regs[1] = {};

    $regs[0]->{"p"} = 0;
    $regs[1]->{"p"} = 1;


    my @queues;

    $queues[0] = [];
    $queues[1] = [];


    my @ip = (0, 0);

    my $send_count = 0;



    sub step {

        my ($p, $program, $regs, $queues, $ip, $send_count_ref) = @_;


        if ($ip->[$p] < 0 || $ip->[$p] >= scalar(@$program)) {
            return 0;
        }


        my ($op, @args) = @{$program->[$ip->[$p]]};

        my $r = $regs->[$p];


        if ($op eq "snd") {

            my $v = val($args[0], $r);

            push @{$queues->[1-$p]}, $v;

            if ($p == 1) {
                $$send_count_ref++;
            }

        }
        elsif ($op eq "set") {

            $r->{$args[0]} = val($args[1], $r);

        }
        elsif ($op eq "add") {

            $r->{$args[0]} += val($args[1], $r);

        }
        elsif ($op eq "mul") {

            $r->{$args[0]} *= val($args[1], $r);

        }
        elsif ($op eq "mod") {

            $r->{$args[0]} %= val($args[1], $r);

        }
        elsif ($op eq "rcv") {

            if (scalar(@{$queues->[$p]})) {

                $r->{$args[0]} = shift @{$queues->[$p]};

            }
            else {

                return 0;

            }

        }
        elsif ($op eq "jgz") {

            if (val($args[0], $r) > 0) {

                $ip->[$p] += val($args[1], $r);

                return 1;
            }

        }


        $ip->[$p]++;

        return 1;
    }



    while (1) {

        my $p0 = step(0, $program, \@regs, \@queues, \@ip, \$send_count);
        my $p1 = step(1, $program, \@regs, \@queues, \@ip, \$send_count);


        last if !$p0 && !$p1;
    }


    return $send_count;
}



my $p1 = run_part1(\@program);

my $p2 = run_part2(\@program);


print "2017 day18: pl_ans_1: $p1\n";
print "2017 day18: pl_ans_2: $p2\n";
