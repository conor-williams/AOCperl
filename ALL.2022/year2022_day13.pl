#!/usr/bin/perl
use strict;
use warnings;

my $file = shift or die "usage: $0 input\n";

open(my $fh,"<",$file) or die $!;

my @lines=<$fh>;
close($fh);

chomp @lines;

sub parse_packet {

    my ($s)=@_;

    my @stack;
    my $root;
    my $num="";

    foreach my $c (split //,$s){

        if($c =~ /\d/){
            $num.=$c;
        }
        else{

            if(length($num)){
                push @{$stack[-1]},0+$num;
                $num="";
            }

            if($c eq "["){
                my $new=[];

                if(@stack){
                    push @{$stack[-1]},$new;
                }
                else{
                    $root=$new;
                }

                push @stack,$new;
            }
            elsif($c eq "]"){
                pop @stack;
            }
        }
    }

    return $root;
}

sub compare {

    my ($l,$r)=@_;

    my $li=ref($l) eq "";
    my $ri=ref($r) eq "";

    if($li && $ri){

        return -1 if $l<$r;
        return 1 if $l>$r;
        return 0;
    }

    $l=[$l] if $li;
    $r=[$r] if $ri;

    my $i=0;

    while($i<@$l && $i<@$r){

        my $ans=compare($l->[$i],$r->[$i]);

        return $ans if $ans!=0;

        $i++;
    }

    return -1 if @$l<@$r;
    return 1 if @$l>@$r;

    return 0;
}

my @pairs;
my @packets;
my @cur;

foreach my $line (@lines){

    if($line eq ""){

        if(@cur==2){

            push @pairs,[$cur[0],$cur[1]];
            push @packets,@cur;
        }

        @cur=();
    }
    else{

        push @cur,parse_packet($line);
    }
}

if(@cur==2){

    push @pairs,[$cur[0],$cur[1]];
    push @packets,@cur;
}

my $total=0;

for(my $i=0;$i<@pairs;$i++){

    if(compare($pairs[$i][0],$pairs[$i][1])<0){
        $total += $i+1;
    }
}

my $div1=[[2]];
my $div2=[[6]];

push @packets,$div1,$div2;

my $changed=1;

while($changed){

    $changed=0;

    for(my $i=0;$i<@packets-1;$i++){

        if(compare($packets[$i],$packets[$i+1])>0){

            my $tmp=$packets[$i];
            $packets[$i]=$packets[$i+1];
            $packets[$i+1]=$tmp;

            $changed=1;
        }
    }
}

my ($pos1,$pos2);

for(my $i=0;$i<@packets;$i++){

    $pos1=$i+1 if $packets[$i]==$div1;
    $pos2=$i+1 if $packets[$i]==$div2;
}

print "2022 day13: pl_ans_1: $total\n";
print "2022 day13: pl_ans_2: ",$pos1*$pos2,"\n";
