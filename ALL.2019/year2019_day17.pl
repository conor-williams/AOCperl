#!/usr/bin/perl
use strict;
use warnings;


# ============================================================
# Intcode
# ============================================================

package Intcode;

sub new {
    my ($class,$program)=@_;

    my %mem;
    for my $i (0..$#$program) {
        $mem{$i}=$program->[$i];
    }

    return bless {
        mem => \%mem,
        ip => 0,
        rel => 0,
        halted => 0,
    },$class;
}


sub read {
    my ($self,$a)=@_;
    return $self->{mem}{$a} // 0;
}


sub write {
    my ($self,$a,$v)=@_;
    $self->{mem}{$a}=$v;
}


sub get {
    my ($self,$mode,$off)=@_;

    my $v=$self->read($self->{ip}+$off);

    return $self->read($v) if $mode==0;
    return $v if $mode==1;
    return $self->read($self->{rel}+$v) if $mode==2;

    die "bad mode";
}


sub addr {
    my ($self,$mode,$off)=@_;

    my $v=$self->read($self->{ip}+$off);

    return $v if $mode==0;
    return $self->{rel}+$v if $mode==2;

    die "bad addr";
}


sub run {

    my ($self,$input)=@_;

    my @out;
    my $ipos=0;


    while(1){

        my $ins=$self->read($self->{ip});

        my $op=$ins%100;

        my $m1=int($ins/100)%10;
        my $m2=int($ins/1000)%10;
        my $m3=int($ins/10000)%10;


        if($op==1){

            $self->write(
                $self->addr($m3,3),
                $self->get($m1,1)+$self->get($m2,2)
            );

            $self->{ip}+=4;

        }
        elsif($op==2){

            $self->write(
                $self->addr($m3,3),
                $self->get($m1,1)*$self->get($m2,2)
            );

            $self->{ip}+=4;

        }
        elsif($op==3){

            my $c=$self->addr($m1,1);

            $self->write(
                $c,
                ord(substr($input->[$ipos++],0,1))
            );

            $self->{ip}+=2;

        }
        elsif($op==4){

            push @out,$self->get($m1,1);

            $self->{ip}+=2;

        }
        elsif($op==5){

            if($self->get($m1,1)){
                $self->{ip}=$self->get($m2,2);
            }
            else{
                $self->{ip}+=3;
            }

        }
        elsif($op==6){

            if(!$self->get($m1,1)){
                $self->{ip}=$self->get($m2,2);
            }
            else{
                $self->{ip}+=3;
            }

        }
        elsif($op==7){

            $self->write(
                $self->addr($m3,3),
                $self->get($m1,1)<$self->get($m2,2)?1:0
            );

            $self->{ip}+=4;

        }
        elsif($op==8){

            $self->write(
                $self->addr($m3,3),
                $self->get($m1,1)==$self->get($m2,2)?1:0
            );

            $self->{ip}+=4;

        }
        elsif($op==9){

            $self->{rel}+=$self->get($m1,1);
            $self->{ip}+=2;

        }
        elsif($op==99){

            $self->{halted}=1;
            last;

        }
        else{
            die "opcode $op";
        }
    }

    return @out;
}


package main;


# ============================================================
# Grid
# ============================================================


sub grid_from_output {

    my @out=@_;

    my $txt=join("",map {chr($_)} @out);

    my @rows=map {[split //]} split /\n/,$txt;

    return \@rows;
}


sub scaffold {

    my ($g,$x,$y)=@_;

    return 0 if $y<0 || $x<0;
    return 0 if $y>$#$g;
    return 0 if $x>$#{$g->[$y]};

    return $g->[$y][$x] eq '#';
}


sub alignment {

    my ($g)=@_;

    my $sum=0;

    for my $y (1..$#$g-1){
        for my $x (1..$#{$g->[$y]}-1){

            next unless $g->[$y][$x] eq '#';

            if(
                scaffold($g,$x,$y-1) &&
                scaffold($g,$x,$y+1) &&
                scaffold($g,$x-1,$y) &&
                scaffold($g,$x+1,$y)
            ){
                $sum += $x*$y;
            }
        }
    }

    return $sum;
}



# ============================================================
# Path extraction
# ============================================================


my @DIR=(
 [0,-1],
 [1,0],
 [0,1],
 [-1,0]
);


sub find_robot {

    my $g=shift;

    for my $y(0..$#$g){
        for my $x(0..$#{$g->[$y]}){

            my $c=$g->[$y][$x];

            return ($x,$y,0) if $c eq '^';
            return ($x,$y,1) if $c eq '>';
            return ($x,$y,2) if $c eq 'v';
            return ($x,$y,3) if $c eq '<';

        }
    }
}



sub extract_path {

    my $g=shift;

    my ($x,$y,$d)=find_robot($g);

    my @path;


    while(1){

        my $turned=0;


        for my $t (
            ["L",($d+3)%4],
            ["R",($d+1)%4]
        ){

            my ($name,$nd)=@$t;

            my ($dx,$dy)=@{$DIR[$nd]};

            if(scaffold($g,$x+$dx,$y+$dy)){

                push @path,$name;
                $d=$nd;
                $turned=1;
                last;
            }
        }


        last unless $turned;


        my $steps=0;

        my ($dx,$dy)=@{$DIR[$d]};

        while(scaffold($g,$x+$dx,$y+$dy)){

            $x+=$dx;
            $y+=$dy;
            $steps++;
        }

        push @path,$steps;
    }


    return @path;
}



# ============================================================
# Compression
# ============================================================


sub str_tokens {
    return join(",",@_);
}


sub fits {
    return length(str_tokens(@_))<=20;
}


sub replace {

    my ($seq,$pat,$rep)=@_;

    my @out;
    my $i=0;

    while($i<@$seq){

        my $match=1;

        for my $j(0..$#$pat){
            $match=0 if !defined $seq->[$i+$j] ||
                       $seq->[$i+$j] ne $pat->[$j];
        }

        if($match){
            push @out,$rep;
            $i+=@$pat;
        }
        else{
            push @out,$seq->[$i];
            $i++;
        }
    }

    return @out;
}


sub compress {

    my @path=@_;

    for my $a(1..10){

        my @A=@path[0..$a-1];
        next unless fits(@A);

        my @p1=replace(\@path,\@A,"A");


        my $first;
        for(0..$#p1){
            if($p1[$_] ne "A"){
                $first=$_;
                last;
            }
        }

        next unless defined $first;


        for my $b(1..10){

            my @B=@p1[$first..$first+$b-1];
            next unless fits(@B);

            my @p2=replace(\@p1,\@B,"B");


            my $f2;
            for(0..$#p2){
                if($p2[$_] ne "A" && $p2[$_] ne "B"){
                    $f2=$_;
                    last;
                }
            }

            next unless defined $f2;


            for my $c(1..10){

                my @C=@p2[$f2..$f2+$c-1];
                next unless fits(@C);

                my @p3=replace(\@p2,\@C,"C");


                my $ok=1;
                for(@p3){
                    $ok=0 unless /^(A|B|C)$/;
                }

                if($ok){

                    return (
                        join(",",@p3),
                        str_tokens(@A),
                        str_tokens(@B),
                        str_tokens(@C)
                    );
                }
            }
        }
    }

    die "no compression";
}



# ============================================================
# MAIN
# ============================================================


my $file=shift @ARGV;

open my $fh,"<",$file;
my @program=split /,/,<$fh>;
close $fh;


my $vm=Intcode->new(\@program);

my @out=$vm->run([]);

my $grid=grid_from_output(@out);


print "2019 day17: pl_ans_1: ",
      alignment($grid),"\n";


my @path=extract_path($grid);


my ($main,$A,$B,$C)=compress(@path);


@program=split /,/,join(",",@program);

$program[0]=2;


my $script =
    $main."\n".
    $A."\n".
    $B."\n".
    $C."\n".
    "n\n";


my @input=split //,$script;


my $vm2=Intcode->new(\@program);

my @result=$vm2->run(\@input);


print "2019 day17: pl_ans_2: ",
      $result[-1],"\n";
