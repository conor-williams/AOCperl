#!/usr/bin/perl
use strict;
use warnings;

# Advent of Code 2021 Day 23
# Amphipod - pure Perl, no dependencies

my $file = shift @ARGV or die "usage: perl year2021_day23.pl input.txt\n";

open my $fh, "<", $file or die "$file: $!\n";
my @lines = <$fh>;
close $fh;

chomp @lines;


my %ENERGY = (
    A => 1,
    B => 10,
    C => 100,
    D => 1000
);

my @ROOM_X = (2,4,6,8);
my @ROOM_TYPE = qw(A B C D);


sub parse_input {
    my (@lines) = @_;

    my @rooms = ( [], [], [], [] );

    for my $line (@lines) {
        my @c = ($line =~ /([ABCD])/g);
        next unless @c;

        for my $i (0..3) {
            push @{$rooms[$i]}, $c[$i];
        }
    }

    return \@rooms;
}


sub copy_rooms {
    my ($rooms) = @_;

    return [
        [ @{$rooms->[0]} ],
        [ @{$rooms->[1]} ],
        [ @{$rooms->[2]} ],
        [ @{$rooms->[3]} ]
    ];
}


sub encode_state {
    my ($hall,$rooms) = @_;

    return join "",
        @$hall,
        map { join "", @$_ } @$rooms;
}


sub clone_state {
    my ($hall,$rooms) = @_;

    my @h = @$hall;
    my @r = map { [@$_] } @$rooms;

    return (\@h,\@r);
}


# ----------------------------
# simple binary min heap
# ----------------------------

sub heap_push {
    my ($heap,$item) = @_;

    push @$heap,$item;

    my $i = @$heap - 1;

    while ($i > 0) {

        my $p = int(($i-1)/2);

        last if $heap->[$p][0] <= $heap->[$i][0];

        ($heap->[$p],$heap->[$i]) =
        ($heap->[$i],$heap->[$p]);

        $i=$p;
    }
}


sub heap_pop {

    my ($heap)=@_;

    return undef unless @$heap;

    my $out=$heap->[0];

    my $last=pop @$heap;

    if (@$heap) {

        $heap->[0]=$last;

        my $i=0;

        while (1) {

            my $l=$i*2+1;
            my $r=$i*2+2;
            my $small=$i;

            if ($l < @$heap &&
                $heap->[$l][0] < $heap->[$small][0]) {
                $small=$l;
            }

            if ($r < @$heap &&
                $heap->[$r][0] < $heap->[$small][0]) {
                $small=$r;
            }

            last if $small==$i;

            ($heap->[$small],$heap->[$i]) =
            ($heap->[$i],$heap->[$small]);

            $i=$small;
        }
    }

    return $out;
}


sub path_clear {

    my ($hall,$a,$b)=@_;

    if ($a<$b) {

        for my $i ($a+1..$b) {
            return 0 if $hall->[$i] ne ".";
        }

    } else {

        for my $i ($b..$a-1) {
            return 0 if $hall->[$i] ne ".";
        }
    }

    return 1;
}

sub solved {
    my ($rooms,$depth)=@_;

    for my $i (0..3) {

        return 0 unless @{$rooms->[$i]} == $depth;

        for my $c (@{$rooms->[$i]}) {
            return 0 unless $c eq $ROOM_TYPE[$i];
        }
    }

    return 1;
}


sub moves {

    my ($hall,$rooms,$depth)=@_;

    my @out;


    # -------------------------
    # hallway -> room
    # -------------------------

    for my $h (0..10) {

        my $c=$hall->[$h];

        next if $c eq ".";

        my $target;

        for my $i (0..3) {
            if ($ROOM_TYPE[$i] eq $c) {
                $target=$i;
                last;
            }
        }


        my $room=$rooms->[$target];

        # room must contain only same type
        my $ok=1;

        for (@$room) {
            $ok=0 if $_ ne $c;
        }

        next unless $ok;

        my $door=$ROOM_X[$target];

        next unless path_clear($hall,$h,$door);


        my $steps=abs($h-$door)+($depth-@$room);

        my ($nh,$nr)=clone_state($hall,$rooms);

        $nh->[$h]=".";

        unshift @{$nr->[$target]},$c;


        push @out,[
            $steps*$ENERGY{$c},
            $nh,
            $nr
        ];
    }



    # -------------------------
    # room -> hallway
    # -------------------------

    for my $r (0..3) {

        my $room=$rooms->[$r];

        next unless @$room;


        my $c=$room->[0];


        # already correct and settled
        my $settled=1;

        for (@$room) {
            $settled=0 if $_ ne $ROOM_TYPE[$r];
        }

        next if $settled;


        my $door=$ROOM_X[$r];


        for my $h (0,1,3,5,7,9,10) {


            next unless $hall->[$h] eq ".";


            next unless path_clear($hall,$door,$h);


            my $steps=abs($door-$h)+
                      ($depth-@$room+1);


            my ($nh,$nr)=clone_state($hall,$rooms);


            $nr->[$r]=[
                @{$nr->[$r]}[1..$#{$nr->[$r]}]
            ];


            $nh->[$h]=$c;


            push @out,[
                $steps*$ENERGY{$c},
                $nh,
                $nr
            ];
        }
    }


    return @out;
}



sub solve {

    my ($start)=@_;

    my $depth=@{$start->[0]};


    my @hall=(".") x 11;


    my $start_key=encode_state(
        \@hall,
        $start
    );


    my @heap;

    heap_push(
        \@heap,
        [
            0,
            \@hall,
            $start,
            $start_key
        ]
    );


    my %seen;


    while (@heap) {


        my $node=heap_pop(\@heap);


        my ($cost,$hall,$rooms,$key)=@$node;


        next if exists $seen{$key}
             && $seen{$key} <= $cost;


        $seen{$key}=$cost;


        return $cost
            if solved($rooms,$depth);



        for my $m (moves($hall,$rooms,$depth)) {


            my ($extra,$nh,$nr)=@$m;


            my $newkey=encode_state(
                $nh,
                $nr
            );


            next if exists $seen{$newkey}
                 && $seen{$newkey} <= $cost+$extra;


            heap_push(
                \@heap,
                [
                    $cost+$extra,
                    $nh,
                    $nr,
                    $newkey
                ]
            );
        }
    }


    die "no solution\n";
}



sub expand_part2 {

    my ($rooms)=@_;


    my @extra = (
        [qw(D D)],
        [qw(C B)],
        [qw(B A)],
        [qw(A C)]
    );


    my @r;


    for my $i (0..3) {

        $r[$i]=[
            $rooms->[$i][0],
            @{$extra[$i]},
            $rooms->[$i][1]
        ];
    }


    return \@r;
}



# -------------------------
# MAIN
# -------------------------

my $rooms=parse_input(@lines);


my $p1=solve($rooms);

print "2021 day23: pl_ans_1: $p1\n";


my $rooms2=expand_part2($rooms);

my $p2=solve($rooms2);

print "2021 day23: pl_ans_2: $p2\n";
