#!/usr/bin/perl
use strict;
use warnings;


my $file=$ARGV[0];

open(my $fh,"<",$file) or die $!;

my @blueprints;

while(<$fh>) {

    chomp;
    next if $_ eq "";

    my @n = /(\d+)/g;

    push @blueprints, {
        ore_bot  => [$n[1],0,0,0],
        clay_bot => [$n[2],0,0,0],
        obs_bot  => [$n[3],$n[4],0,0],
        geo_bot  => [$n[5],0,$n[6],0],
    };
}

close($fh);



my $ORE=0;
my $CLAY=1;
my $OBS=2;
my $GEO=3;



sub max {

    return $_[0] > $_[1] ? $_[0] : $_[1];
}



sub geode_max {

    my ($bp,$limit)=@_;


    my @costs=(
        $bp->{ore_bot},
        $bp->{clay_bot},
        $bp->{obs_bot},
        $bp->{geo_bot}
    );


    my @max_cost=(0,0,0,999999);


    for my $c (@costs) {

        for(my $i=0;$i<4;$i++) {

            $max_cost[$i]=$c->[$i]
                if $c->[$i] > $max_cost[$i];
        }
    }


    my %cache;

    my $best=0;



    sub dfs19 {

        my (
            $t,
            $ore,$clay,$obs,$geo,
            $or,$cr,$br,$gr,
            $bp,$limit,
            $max_cost,
            $cache,
            $best_ref
        )=@_;


        if($t==$limit) {

            $$best_ref =
                max($$best_ref,$geo);

            return $geo;
        }



        my $remain=$limit-$t;


        # optimistic bound
        my $possible =
            $geo +
            $gr*$remain +
            ($remain*($remain-1))/2;


        return 0 if $possible <= $$best_ref;



        # cap resources (important for speed)

        $ore =
            $max_cost->[0]*$remain
            if $ore > $max_cost->[0]*$remain;

        $clay =
            $max_cost->[1]*$remain
            if $clay > $max_cost->[1]*$remain;

        $obs =
            $max_cost->[2]*$remain
            if $obs > $max_cost->[2]*$remain;



        my $key=join(",",
            $t,
            $ore,$clay,$obs,$geo,
            $or,$cr,$br,$gr
        );


        return $cache->{$key}
            if exists $cache->{$key};



        my $best_local=0;



        #
        # Always try geode robot first
        #

        if(
            $ore >= $bp->{geo_bot}[0] &&
            $obs >= $bp->{geo_bot}[2]
        ) {

            $best_local=max(
                $best_local,

                dfs19(
                    $t+1,

                    $ore-$bp->{geo_bot}[0]+$or,
                    $clay+$cr,
                    $obs-$bp->{geo_bot}[2]+$br,
                    $geo+$gr,

                    $or,$cr,$br,$gr+1,

                    $bp,$limit,
                    $max_cost,
                    $cache,
                    $best_ref
                )
            );


            $cache->{$key}=$best_local;
            return $best_local;
        }




        # ore robot

        if(
            $or < $max_cost->[0] &&
            $ore >= $bp->{ore_bot}[0]
        ) {

            $best_local=max(
                $best_local,

                dfs19(
                    $t+1,

                    $ore-$bp->{ore_bot}[0]+$or,
                    $clay+$cr,
                    $obs+$br,
                    $geo+$gr,

                    $or+1,$cr,$br,$gr,

                    $bp,$limit,
                    $max_cost,
                    $cache,
                    $best_ref
                )
            );
        }



        # clay robot

        if(
            $cr < $max_cost->[1] &&
            $ore >= $bp->{clay_bot}[0]
        ) {

            $best_local=max(
                $best_local,

                dfs19(
                    $t+1,

                    $ore-$bp->{clay_bot}[0]+$or,
                    $clay+$cr,
                    $obs+$br,
                    $geo+$gr,

                    $or,$cr+1,$br,$gr,

                    $bp,$limit,
                    $max_cost,
                    $cache,
                    $best_ref
                )
            );
        }




        # obsidian robot

        if(
            $ore >= $bp->{obs_bot}[0] &&
            $clay >= $bp->{obs_bot}[1]
        ) {

            $best_local=max(
                $best_local,

                dfs19(
                    $t+1,

                    $ore-$bp->{obs_bot}[0]+$or,
                    $clay-$bp->{obs_bot}[1]+$cr,
                    $obs+$br,
                    $geo+$gr,

                    $or,$cr,$br+1,$gr,

                    $bp,$limit,
                    $max_cost,
                    $cache,
                    $best_ref
                )
            );
        }



        # wait

        $best_local=max(
            $best_local,

            dfs19(
                $t+1,

                $ore+$or,
                $clay+$cr,
                $obs+$br,
                $geo+$gr,

                $or,$cr,$br,$gr,

                $bp,$limit,
                $max_cost,
                $cache,
                $best_ref
            )
        );



        $cache->{$key}=$best_local;


        $$best_ref =
            max($$best_ref,$best_local);


        return $best_local;
    }



    return dfs19(
        0,
        0,0,0,0,
        1,0,0,0,
        $bp,
        $limit,
        \@max_cost,
        \%cache,
        \$best
    );
}



# -------------------------
# Solve
# -------------------------

my $p1=0;

for(my $i=0;$i<@blueprints;$i++) {

    my $g =
        geode_max($blueprints[$i],24);

    $p1 += ($i+1)*$g;
}



my $p2=1;

for(my $i=0;$i<3 && $i<@blueprints;$i++) {

    $p2 *=
        geode_max($blueprints[$i],32);
}



print "2022 day19: pl_ans_1: $p1\n";
print "2022 day19: pl_ans_2: $p2\n";
