use strict;
use warnings;


sub parse {
    my (@lines) = @_;

    my @comps;

    for my $line (@lines) {
        my ($a,$b) = split(/\//,$line);
        push @comps, [$a,$b];
    }

    return \@comps;
}


sub dfs {
    my ($port,$comps,$used,$strength,$length,$results) = @_;

    push @$results, [$length,$strength];

    for my $i (0 .. $#$comps) {

        next if exists $used->{$i};

        my ($a,$b) = @{$comps->[$i]};

        if ($a == $port) {
            $used->{$i}=1;
            dfs(
                $b,
                $comps,
                $used,
                $strength+$a+$b,
                $length+1,
                $results
            );
            delete $used->{$i};
        }
        elsif ($b == $port) {
            $used->{$i}=1;
            dfs(
                $a,
                $comps,
                $used,
                $strength+$a+$b,
                $length+1,
                $results
            );
            delete $used->{$i};
        }
    }
}


sub solve {
    my ($comps)=@_;

    my @results;

    dfs(
        0,
        $comps,
        {},
        0,
        0,
        \@results
    );


    my $part1 = 0;

    for my $r (@results) {
        $part1 = $r->[1] if $r->[1] > $part1;
    }


    my $max_len = 0;

    for my $r (@results) {
        $max_len = $r->[0] if $r->[0] > $max_len;
    }


    my $part2 = 0;

    for my $r (@results) {
        if ($r->[0] == $max_len && $r->[1] > $part2) {
            $part2 = $r->[1];
        }
    }

    return ($part1,$part2);
}


sub main {

    open(my $fh,"<",$ARGV[0]) or die $!;

    my @lines = <$fh>;
    chomp @lines;

    my $comps = parse(@lines);

    my ($p1,$p2)=solve($comps);

    print "2017 day24: pl_ans_1: $p1\n";
    print "2017 day24: pl_ans_2: $p2\n";
}

main();
