#!/usr/bin/perl

use strict;
use warnings;


# -------------------------------------------------
# Group helpers
# -------------------------------------------------

sub make_group
{
    my ($army, $units, $hp, $dmg, $dtype, $init, $weak, $immune) = @_;

    return {
        army   => $army,
        units  => $units,
        hp     => $hp,
        dmg    => $dmg,
        dtype  => $dtype,
        init   => $init,
        weak   => $weak,
        immune => $immune,
    };
}


sub effective_power
{
    my ($g) = @_;

    return $g->{units} * $g->{dmg};
}


sub damage_to
{
    my ($g, $other) = @_;


    return 0
        if exists $other->{immune}{$g->{dtype}};


    if (exists $other->{weak}{$g->{dtype}})
    {
        return effective_power($g) * 2;
    }


    return effective_power($g);
}



# -------------------------------------------------
# Parse input
# -------------------------------------------------

sub parse
{
    my ($file) = @_;


    open(my $fh, '<', $file)
        or die "Cannot open $file: $!";


    my @groups;

    my $army;


    while (my $line = <$fh>)
    {
        chomp $line;

        next if $line eq '';


        if ($line eq "Immune System:")
        {
            $army = "immune";
            next;
        }


        if ($line eq "Infection:")
        {
            $army = "infection";
            next;
        }


        if (
            $line =~
            /(\d+) units each with (\d+) hit points(?: \((.*?)\))? with an attack that does (\d+) (\w+) damage at initiative (\d+)/
        )
        {
            my ($units,$hp,$props,$dmg,$dtype,$init) =
                ($1,$2,$3,$4,$5,$6);


            my %weak;
            my %immune;


            if (defined $props)
            {
                for my $part (split(/; /,$props))
                {
                    if ($part =~ /^weak to (.*)$/)
                    {
                        for my $x (split(/, /,$1))
                        {
                            $weak{$x}=1;
                        }
                    }
                    elsif ($part =~ /^immune to (.*)$/)
                    {
                        for my $x (split(/, /,$1))
                        {
                            $immune{$x}=1;
                        }
                    }
                }
            }


            push @groups,
                make_group(
                    $army,
                    int($units),
                    int($hp),
                    int($dmg),
                    $dtype,
                    int($init),
                    \%weak,
                    \%immune
                );
        }
    }


    close($fh);


    return \@groups;
}



# -------------------------------------------------
# Deep copy groups
# -------------------------------------------------

sub copy_groups
{
    my ($groups)=@_;


    my @copy;


    for my $g (@$groups)
    {
        push @copy,
        {
            army   => $g->{army},
            units  => $g->{units},
            hp     => $g->{hp},
            dmg    => $g->{dmg},
            dtype  => $g->{dtype},
            init   => $g->{init},
            weak   => { %{$g->{weak}} },
            immune => { %{$g->{immune}} },
        };
    }


    return \@copy;
}



# -------------------------------------------------
# Simulation
# -------------------------------------------------

sub simulate
{
    my ($base,$boost)=@_;


    my $groups = copy_groups($base);


    for my $g (@$groups)
    {
        if ($g->{army} eq "immune")
        {
            $g->{dmg} += $boost;
        }
    }



    while (1)
    {
        @$groups =
            grep { $_->{units} > 0 } @$groups;


        my %armies;

        for my $g (@$groups)
        {
            $armies{$g->{army}}=1;
        }


        if (keys(%armies)==1)
        {
            my ($winner)=keys %armies;

            my $units=0;

            $units += $_->{units}
                for @$groups;


            return ($winner,$units);
        }



        # -----------------------------------------
        # Target selection
        # -----------------------------------------

        my %targets;

        my %chosen;


        my @order =
            sort
            {
                effective_power($b)
                <=>
                effective_power($a)
                ||
                $b->{init}
                <=>
                $a->{init}
            }
            @$groups;



        for my $g (@order)
        {
            my @enemies =
                grep
                {
                    $_->{army} ne $g->{army}
                    &&
                    !$chosen{$_}
                }
                @$groups;



            @enemies =
                sort
                {
                    damage_to($g,$b)
                    <=>
                    damage_to($g,$a)
                    ||
                    effective_power($b)
                    <=>
                    effective_power($a)
                    ||
                    $b->{init}
                    <=>
                    $a->{init}
                }
                @enemies;



            if (@enemies &&
                damage_to($g,$enemies[0]) > 0)
            {
                $targets{$g} = $enemies[0];
                $chosen{$enemies[0]}=1;
            }
        }



        # -----------------------------------------
        # Attack
        # -----------------------------------------

        @order =
            sort
            {
                $b->{init}
                <=>
                $a->{init}
            }
            @$groups;


        my $any_kill=0;


        for my $g (@order)
        {
            next if $g->{units} <= 0;
            next unless exists $targets{$g};


            my $t = $targets{$g};


            my $damage =
                damage_to($g,$t);


            my $killed =
                int($damage / $t->{hp});


            $killed = $t->{units}
                if $killed > $t->{units};


            $any_kill=1 if $killed > 0;


            $t->{units} -= $killed;
        }



        if (!$any_kill)
        {
            my $units=0;

            $units += $_->{units}
                for @$groups;


            return ("stalemate",$units);
        }
    }
}



# -------------------------------------------------
# Main
# -------------------------------------------------

my $file = shift @ARGV
    or die "Usage: $0 input.txt\n";


my $base = parse($file);



my ($winner1,$units1) =
    simulate($base,0);


print "2018 day24: pl_ans_1: $units1\n";



for (my $boost=0;;$boost++)
{
    my ($winner,$units) =
        simulate($base,$boost);


    if ($winner eq "immune")
    {
        print "2018 day24: pl_ans_2: $units\n";
        last;
    }
}
