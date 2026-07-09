use strict;
use warnings;

sub parse_input {
    my ($lines) = @_;

    my @rules;
    my @updates;
    my $parsing_rules = 1;

    for my $line (@$lines) {
        chomp $line;
        $line =~ s/^\s+|\s+$//g;

        if ($line eq "") {
            $parsing_rules = 0;
            next;
        }

        if ($parsing_rules) {
            my ($a, $b) = split /\|/, $line;
            push @rules, [int($a), int($b)];
        }
        else {
            push @updates, [map { int($_) } split /,/, $line];
        }
    }

    return (\@rules, \@updates);
}


sub middle {
    my ($update) = @_;
    return $update->[int(@$update / 2)];
}


sub topo_fix {
    my ($update, $adj, $indeg) = @_;

    my @q = grep { $indeg->{$_} == 0 } @$update;

    my %seen;
    $seen{$_} = 1 for @q;

    my @result;

    while (@q) {
        my $x = shift @q;
        push @result, $x;

        for my $nxt (@{$adj->{$x} // []}) {
            if (exists $indeg->{$nxt}) {
                $indeg->{$nxt}--;

                if ($indeg->{$nxt} == 0 && !$seen{$nxt}) {
                    push @q, $nxt;
                    $seen{$nxt} = 1;
                }
            }
        }
    }

    # fallback for missing nodes
    for my $x (@$update) {
        push @result, $x unless grep { $_ == $x } @result;
    }

    return \@result;
}


my $path = $ARGV[0];

open my $fh, '<', $path or die "$path: $!";
my @lines = <$fh>;
close $fh;

my ($rules, $updates) = parse_input(\@lines);


# Part 1
my $p1 = 0;
my @bad_updates;

for my $u (@$updates) {

    my %pos;
    for my $i (0 .. $#$u) {
        $pos{$u->[$i]} = $i;
    }

    my $ok = 1;

    for my $r (@$rules) {
        my ($a, $b) = @$r;

        if (exists $pos{$a} && exists $pos{$b}) {
            if ($pos{$a} > $pos{$b}) {
                $ok = 0;
                last;
            }
        }
    }

    if ($ok) {
        $p1 += middle($u);
    }
    else {
        push @bad_updates, $u;
    }
}


# Part 2
my $p2 = 0;

for my $u (@bad_updates) {

    my %nodes;
    $nodes{$_} = 1 for @$u;

    my %adj;
    my %indeg;

    for my $r (@$rules) {
        my ($a, $b) = @$r;

        if ($nodes{$a} && $nodes{$b}) {
            push @{$adj{$a}}, $b;
            $indeg{$b}++;

            $indeg{$a} //= 0;
        }
    }

    my $fixed = topo_fix($u, \%adj, \%indeg);

    $p2 += middle($fixed);
}


print "2024 day5: pl_ans_1: $p1\n";
print "2024 day5: pl_ans_2: $p2\n";
