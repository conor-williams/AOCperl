#!/usr/bin/perl
use strict;
use warnings;

sub gcd {
    my ($a,$b)=@_;
    while ($b) {
        ($a,$b)=($b,$a%$b);
    }
    return $a;
}

sub lcm {
    my ($a,$b)=@_;
    return int($a / gcd($a,$b) * $b);
}

sub parse {
    my ($text)=@_;

    my (%modules,%outputs);

    for my $line (split /\n/,$text) {

        my ($left,$right)=split / -> /,$line;

        my @dests=split /, /,$right;

        my ($name,$typ);

        if ($left eq "broadcaster") {
            $name="broadcaster";
            $typ="b";
        }
        else {
            $typ=substr($left,0,1);
            $name=substr($left,1);
        }

        $modules{$name}=$typ;
        $outputs{$name}=\@dests;
    }

    return (\%modules,\%outputs);
}

sub build_state {
    my ($modules,$outputs)=@_;

    my (%ff,%cj,%inputs);

    for my $src (keys %$outputs) {
        for my $d (@{ $outputs->{$src} }) {
            push @{ $inputs{$d} }, $src;
        }
    }

    for my $name (keys %$modules) {

        if ($modules->{$name} eq "%") {
            $ff{$name}=0;
        }
        elsif ($modules->{$name} eq "&") {
            for my $src (@{ $inputs{$name} }) {
                $cj{$name}{$src}=0;
            }
        }
    }

    return (\%ff,\%cj,\%inputs);
}

sub press {
    my ($outputs,$modules,$ff,$cj)=@_;

    my @q=(
        ["button","broadcaster",0]
    );

    my ($low,$high)=(0,0);
    my @events;

    my $head=0;

    while ($head < @q) {

        my ($src,$dst,$pulse)=@{ $q[$head++] };

        push @events, [$src,$dst,$pulse];

        if ($pulse==0) {
            $low++;
        }
        else {
            $high++;
        }

        next unless exists $modules->{$dst};

        my $typ=$modules->{$dst};

        if ($typ eq "b") {

            push @q,
                map { [$dst,$_, $pulse] }
                @{ $outputs->{$dst} };

        }
        elsif ($typ eq "%") {

            next if $pulse==1;

            $ff->{$dst}=!$ff->{$dst};

            push @q,
                map { [$dst,$_, $ff->{$dst}] }
                @{ $outputs->{$dst} };
        }
        elsif ($typ eq "&") {

            $cj->{$dst}{$src}=$pulse;

            my $all=1;

            for my $v (values %{ $cj->{$dst} }) {
                $all=0 unless $v==1;
            }

            my $out=$all ? 0 : 1;

            push @q,
                map { [$dst,$_, $out] }
                @{ $outputs->{$dst} };
        }
    }

    return ($low,$high,\@events);
}

sub solve {
    my ($text)=@_;

    my ($modules,$outputs)=parse($text);

    my ($ff,$cj,$inputs)=build_state($modules,$outputs);

    my ($low_total,$high_total)=(0,0);

    for (1..1000) {
        my ($l,$h,$e)=press($outputs,$modules,$ff,$cj);

        $low_total += $l;
        $high_total += $h;
    }

    my $p1=$low_total*$high_total;


    ($ff,$cj,$inputs)=build_state($modules,$outputs);

    my $rx_parent;

    for my $src (keys %$outputs) {
        for my $d (@{ $outputs->{$src} }) {
            if ($d eq "rx") {
                $rx_parent=$src;
            }
        }
    }

    my %seen;
    my $step=0;

    while (keys(%seen) < scalar(@{ $inputs->{$rx_parent} })) {

        $step++;

        my ($l,$h,$events)=press(
            $outputs,$modules,$ff,$cj
        );

        for my $e (@$events) {
            my ($src,$dst,$pulse)=@$e;

            if ($dst eq $rx_parent && $pulse==1) {
                $seen{$src}=$step unless exists $seen{$src};
            }
        }
    }

    my ($p2)=values %seen;

    for my $v (values %seen) {
        $p2=lcm($p2,$v);
    }

    return ($p1,$p2);
}

sub main {

    my $path=$ARGV[0];

    open my $fh,"<",$path or die "$path: $!";

    local $/;
    my $text=<$fh>;

    close $fh;

    my ($p1,$p2)=solve($text);

    print "2023 day20: pl_ans_1: $p1\n";
    print "2023 day20: pl_ans_2: $p2\n";
}

main();
