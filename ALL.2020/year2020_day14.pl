#!/usr/bin/perl
use strict;
use warnings;

# ------------------------------------------------------------
# Advent of Code 2020 Day 14
# Part 1 of 3
# ------------------------------------------------------------

sub update_mask {
    my ($line) = @_;

    $line =~ s/^.*=\s*//;
    chomp($line);

    return $line;
}

sub update_mem {

    my ($mem, $line, $mask) = @_;

    $line =~ /(\d+)/;
    my $key = $1;

    my $val = $mem->{$key};

    for (my $i = 0; $i < length($mask); $i++) {

        my $v = substr($mask, $i, 1);

        if ($v eq 'X') {

            # unchanged

        }
        elsif ($v eq '1') {

            $val |= (1 << (36 - $i - 1));

        }
        elsif ($v eq '0') {

            $val &= ~(1 << (36 - $i - 1));
        }
    }

    $mem->{$key} = $val;

    return $mem;
}

sub run {

    my ($code) = @_;

    my %mem;
    my $mask = "";

    foreach my $line (@$code) {

        if ($line =~ /mask/) {

            $mask = update_mask($line);
            next;
        }

        elsif ($line =~ /mem/) {

            if ($line =~ /mem\[(\d+)\]\s*=\s*(\d+)/) {

                my ($addr, $value) = ($1, $2);

                $mem{$addr} = $value;

                update_mem(\%mem, $line, $mask);
            }
        }
    }

    my $sum = 0;

    foreach my $k (keys %mem) {
        $sum += $mem{$k};
    }

    return $sum;
}

# ------------------------------------------------------------
# Part 2 helpers begin here
# ------------------------------------------------------------

sub permute_masks {

    my ($mask) = @_;

    my @bits;

    for (my $i = 0; $i < length($mask); $i++) {

        if (substr($mask, $i, 1) eq 'X') {
            push @bits, $i;
        }
    }

    my @masks;

    my $count = @bits;

    my $total = 1 << $count;

    for (my $n = 0; $n < $total; $n++) {

        my $new = $mask;

        for (my $b = 0; $b < $count; $b++) {

            my $bit = ($n >> $b) & 1;

            my $char = $bit ? '1' : '2';

            substr($new, $bits[$b], 1) = $char;
        }

        push @masks, $new;
    }

    return @masks;
}

# ------------------------------------------------------------
# Part 2
# ------------------------------------------------------------

sub update_addr {

    my ($addr, $mask) = @_;

    my @addresses;

    my @masks = permute_masks($mask);

    foreach my $m (@masks) {

        my $a = $addr;

        for (my $i = 0; $i < length($m); $i++) {

            my $v = substr($m, $i, 1);

            if ($v eq '1') {

                $a |= (1 << (36 - $i - 1));

            }
            elsif ($v eq '2') {

                $a &= ~(1 << (36 - $i - 1));
            }
        }

        push @addresses, $a;
    }

    return @addresses;
}

sub update_mem_part2 {

    my ($mem, $line, $mask) = @_;

    my @nums = ($line =~ /(\d+)/g);

    my $target_addr  = $nums[0];
    my $target_value = $nums[1];

    my @addrs = update_addr($target_addr, $mask);

    foreach my $addr (@addrs) {

        $mem->{$addr} = $target_value;
    }

    return $mem;
}

sub run_part2 {

    my ($code) = @_;

    my %mem;
    my $mask = "";

    foreach my $line (@$code) {

        if ($line =~ /mask/) {

            $mask = update_mask($line);

        }
        elsif ($line =~ /mem/) {

            update_mem_part2(
                \%mem,
                $line,
                $mask
            );
        }
    }

    my $sum = 0;

    foreach my $key (keys %mem) {

        $sum += $mem{$key};
    }

    return $sum;
}

# ------------------------------------------------------------
# Main program follows
# ------------------------------------------------------------

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

my $file = shift;

open(my $fh, "<", $file) or die $!;

my @code;

while (<$fh>) {

    chomp;

    push @code, $_ if length($_);
}

close($fh);


my $result = run(\@code);

print "2020 day14: pl_ans_1: $result\n";


my $result2 = run_part2(\@code);

print "2020 day14: pl_ans_2: $result2\n";
