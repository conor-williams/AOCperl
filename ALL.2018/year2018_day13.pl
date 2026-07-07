#!/usr/bin/perl

use strict;
use warnings;

# -------------------------------------------------
# Directions
# -------------------------------------------------

use constant {
    UP    => 0,
    RIGHT => 1,
    DOWN  => 2,
    LEFT  => 3,
};

my @DX = (0, 1, 0, -1);
my @DY = (-1, 0, 1, 0);

# -------------------------------------------------
# Parse input
# -------------------------------------------------

sub parse
{
    my (@lines) = @_;

    my @grid;
    my @carts;

    for my $line (@lines)
    {
        chomp $line;
        push @grid, [ split //, $line ];
    }

    for my $y (0 .. $#grid)
    {
        for my $x (0 .. $#{$grid[$y]})
        {
            my $c = $grid[$y][$x];

            if ($c eq '^')
            {
                push @carts, {
                    x     => $x,
                    y     => $y,
                    d     => UP,
                    turns => 0,
                    dead  => 0,
                };

                $grid[$y][$x] = '|';
            }
            elsif ($c eq 'v')
            {
                push @carts, {
                    x     => $x,
                    y     => $y,
                    d     => DOWN,
                    turns => 0,
                    dead  => 0,
                };

                $grid[$y][$x] = '|';
            }
            elsif ($c eq '<')
            {
                push @carts, {
                    x     => $x,
                    y     => $y,
                    d     => LEFT,
                    turns => 0,
                    dead  => 0,
                };

                $grid[$y][$x] = '-';
            }
            elsif ($c eq '>')
            {
                push @carts, {
                    x     => $x,
                    y     => $y,
                    d     => RIGHT,
                    turns => 0,
                    dead  => 0,
                };

                $grid[$y][$x] = '-';
            }
        }
    }

    return (\@grid, \@carts);
}

# -------------------------------------------------
# Turn helpers
# -------------------------------------------------

sub turn_left
{
    my ($d) = @_;
    return ($d + 3) % 4;
}

sub turn_right
{
    my ($d) = @_;
    return ($d + 1) % 4;
}

# -------------------------------------------------
# Move one cart
# -------------------------------------------------

sub move_cart
{
    my ($grid, $cart) = @_;

    $cart->{x} += $DX[$cart->{d}];
    $cart->{y} += $DY[$cart->{d}];

    my $piece = $grid->[$cart->{y}][$cart->{x}];

    # curves

    if ($piece eq '/')
    {
        if    ($cart->{d} == UP)    { $cart->{d} = RIGHT; }
        elsif ($cart->{d} == RIGHT) { $cart->{d} = UP; }
        elsif ($cart->{d} == DOWN)  { $cart->{d} = LEFT; }
        elsif ($cart->{d} == LEFT)  { $cart->{d} = DOWN; }
    }
    elsif ($piece eq '\\')
    {
        if    ($cart->{d} == UP)    { $cart->{d} = LEFT; }
        elsif ($cart->{d} == LEFT)  { $cart->{d} = UP; }
        elsif ($cart->{d} == DOWN)  { $cart->{d} = RIGHT; }
        elsif ($cart->{d} == RIGHT) { $cart->{d} = DOWN; }
    }

    # intersections

    elsif ($piece eq '+')
    {
        if (($cart->{turns} % 3) == 0)
        {
            $cart->{d} = turn_left($cart->{d});
        }
        elsif (($cart->{turns} % 3) == 2)
        {
            $cart->{d} = turn_right($cart->{d});
        }

        $cart->{turns}++;
    }
}

# -------------------------------------------------
# Part 1
# -------------------------------------------------

sub solve_part1
{
    my ($grid, $carts) = @_;

    while (1)
    {
        @$carts = sort {
            $a->{y} <=> $b->{y}
            ||
            $a->{x} <=> $b->{x}
        } @$carts;

        for my $cart (@$carts)
        {
            move_cart($grid, $cart);

            for my $other (@$carts)
            {
                next if $other == $cart;

                if ($cart->{x} == $other->{x}
                 && $cart->{y} == $other->{y})
                {
                    return ($cart->{x}, $cart->{y});
                }
            }
        }
    }
}

# -------------------------------------------------
# Part 2
# -------------------------------------------------

sub solve_part2
{
    my ($grid, $carts) = @_;

    while (1)
    {
        @$carts = sort {
            $a->{y} <=> $b->{y}
            ||
            $a->{x} <=> $b->{x}
        } @$carts;

        for my $cart (@$carts)
        {
            next if $cart->{dead};

            move_cart($grid, $cart);

            for my $other (@$carts)
            {
                next if $other->{dead};
                next if $other == $cart;

                if ($cart->{x} == $other->{x}
                 && $cart->{y} == $other->{y})
                {
                    $cart->{dead}  = 1;
                    $other->{dead} = 1;
                    last;
                }
            }
        }

        @$carts = grep { !$_->{dead} } @$carts;

        if (@$carts == 1)
        {
            return ($carts->[0]{x}, $carts->[0]{y});
        }
    }
}

# -------------------------------------------------
# Main
# -------------------------------------------------

my $file = shift @ARGV or die "Usage: $0 input.txt\n";

open(my $fh, '<', $file) or die "Cannot open $file: $!";

my @lines = <$fh>;

close($fh);

my ($grid1, $carts1) = parse(@lines);
my ($p1x, $p1y) = solve_part1($grid1, $carts1);

my ($grid2, $carts2) = parse(@lines);
my ($p2x, $p2y) = solve_part2($grid2, $carts2);

print "2018 day13: pl_ans_1: $p1x,$p1y\n";
print "2018 day13: pl_ans_2: $p2x,$p2y\n";
