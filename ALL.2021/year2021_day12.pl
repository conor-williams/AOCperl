use strict;
use warnings;


my $file = $ARGV[0];

open my $fh, "<", $file or die "$!\n";


my %graph;

while (<$fh>) {

    chomp;

    next unless /\S/;

    my ($a,$b) = split /-/;

    push @{$graph{$a}}, $b;
    push @{$graph{$b}}, $a;
}

close $fh;



sub is_small {

    my ($node) = @_;

    return $node =~ /^[a-z]+$/;
}



sub dfs {

    my ($node,$graph,$visited,$used_double) = @_;

    return 1 if $node eq "end";

    my $paths = 0;


    for my $next (@{$graph->{$node}}) {

        next if $next eq "start";


        if (is_small($next)) {

            if (!exists $visited->{$next}) {

                my %new = %$visited;
                $new{$next}=1;

                $paths += dfs(
                    $next,
                    $graph,
                    \%new,
                    $used_double
                );

            }
            elsif (!$used_double) {

                $paths += dfs(
                    $next,
                    $graph,
                    $visited,
                    1
                );
            }

        }
        else {

            $paths += dfs(
                $next,
                $graph,
                $visited,
                $used_double
            );
        }
    }


    return $paths;
}



my %start = ("start"=>1);


my $p1 = dfs(
    "start",
    \%graph,
    \%start,
    1
);


my $p2 = dfs(
    "start",
    \%graph,
    \%start,
    0
);


print "2021 day12: pl_ans_1: $p1\n";
print "2021 day12: pl_ans_2: $p2\n";
