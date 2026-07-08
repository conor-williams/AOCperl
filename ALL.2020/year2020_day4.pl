#!/usr/bin/perl
use strict;
use warnings;

sub parse_passports {
    my ($lines) = @_;
    my @passports;
    my %current;

    foreach my $line (@$lines) {
        chomp $line;

        if ($line eq "") {
            push @passports, { %current };
            %current = ();
            next;
        }

        foreach my $part (split /\s+/, $line) {
            my ($k,$v) = split /:/, $part;
            $current{$k} = $v;
        }
    }

    push @passports, { %current } if %current;

    return @passports;
}

sub valid_part1 {
    my ($p) = @_;

    foreach my $k (qw(byr iyr eyr hgt hcl ecl pid)) {
        return 0 unless exists $p->{$k};
    }

    return 1;
}

sub valid_part2 {
    my ($p) = @_;

    return 0 unless valid_part1($p);

    return 0 unless $p->{byr}=~/^\d+$/;
    return 0 unless $p->{iyr}=~/^\d+$/;
    return 0 unless $p->{eyr}=~/^\d+$/;

    return 0 unless $p->{byr}>=1920 && $p->{byr}<=2002;
    return 0 unless $p->{iyr}>=2010 && $p->{iyr}<=2020;
    return 0 unless $p->{eyr}>=2020 && $p->{eyr}<=2030;

    if($p->{hgt}=~/^(\d+)cm$/){
        return 0 unless $1>=150 && $1<=193;
    }
    elsif($p->{hgt}=~/^(\d+)in$/){
        return 0 unless $1>=59 && $1<=76;
    }
    else{
        return 0;
    }

    return 0 unless $p->{hcl}=~/^#[0-9a-f]{6}$/;

    my %eye=map {$_=>1} qw(amb blu brn gry grn hzl oth);
    return 0 unless exists $eye{$p->{ecl}};

    return 0 unless $p->{pid}=~/^\d{9}$/;

    return 1;
}

my $file=shift;

open(my $fh,"<",$file) or die;
my @lines=<$fh>;
close($fh);

my @passports=parse_passports(\@lines);

my ($p1,$p2)=(0,0);

foreach my $p (@passports){
    $p1++ if valid_part1($p);
    $p2++ if valid_part2($p);
}

print "2020 day4: pl_ans_1: $p1\n";
print "2020 day4: pl_ans_2: $p2\n";
