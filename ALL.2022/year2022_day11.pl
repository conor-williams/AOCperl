#!/usr/bin/perl
use strict;
use warnings;

my $file = shift or die "usage: $0 input\n";

local $/ = "";

open(my $fh,"<",$file) or die $!;
my @blocks = <$fh>;
close($fh);

my @monkeys;

for my $b (@blocks){

    my @lines = split /\n/,$b;

    my @items = ($lines[1]=~/(\d+)/g);

    my ($op) = $lines[2]=~/=\s*(.*)$/;

    my ($div)= $lines[3]=~/(\d+)/;
    my ($t)=   $lines[4]=~/(\d+)/;
    my ($f)=   $lines[5]=~/(\d+)/;

    push @monkeys,{
        items=>[@items],
        op=>$op,
        div=>$div,
        t=>$t,
        f=>$f,
        count=>0
    };
}

sub run{

    my ($orig,$rounds,$relief,$mod)=@_;

    my @m;

    for my $x (@$orig){
        push @m,{
            %$x,
            items=>[ @{$x->{items}} ],
            count=>0
        };
    }

    for(1..$rounds){

        for my $monkey (@m){

            while(@{$monkey->{items}}){

                my $old = shift @{$monkey->{items}};

                $monkey->{count}++;

                my $new;

                if($monkey->{op}=~/old \* old/){
                    $new=$old*$old;
                }
                elsif($monkey->{op}=~/old \+ (\d+)/){
                    $new=$old+$1;
                }
                elsif($monkey->{op}=~/old \* (\d+)/){
                    $new=$old*$1;
                }
                else{
                    die "unknown op $monkey->{op}";
                }

                if($relief){
                    $new=int($new/3);
                }

                if(defined $mod){
                    $new %= $mod;
                }

                if($new % $monkey->{div}==0){
                    push @{$m[$monkey->{t}]{items}},$new;
                }
                else{
                    push @{$m[$monkey->{f}]{items}},$new;
                }
            }
        }
    }

    my @counts = sort{$b<=>$a} map $_->{count},@m;

    return $counts[0]*$counts[1];
}

my $p1 = run(\@monkeys,20,1,undef);

my $mod=1;
$mod *= $_->{div} for @monkeys;

my $p2 = run(\@monkeys,10000,0,$mod);

print "2022 day11: pl_ans_1: $p1\n";
print "2022 day11: pl_ans_2: $p2\n";
