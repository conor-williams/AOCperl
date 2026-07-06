use strict;
use warnings;

open my $fh, "<", $ARGV[0] or die $!;
my @lines = <$fh>;
chomp @lines;

my %bots;
my %rules;
my %outputs;

# ----------------------------
# PARSE
# ----------------------------
for my $line (@lines) {

    if ($line =~ /^value (\d+) goes to bot (\d+)/) {
        push @{ $bots{$2} }, $1;
    }

    elsif ($line =~ /bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)/) {
        $rules{$1} = [$2, $3, $4, $5];
    }
}

# ----------------------------
# INIT QUEUE (PYTHON EXACT)
# ----------------------------
my @q = grep { defined $bots{$_} && @{ $bots{$_} } == 2 } keys %bots;

my $p1;

# ----------------------------
# SIMULATION
# ----------------------------
while (@q) {

    my $bot_id = shift @q;
    next unless defined $bots{$bot_id};
    next unless @{ $bots{$bot_id} } == 2;

    my ($lo, $hi) = sort { $a <=> $b } @{ $bots{$bot_id} };
    $bots{$bot_id} = [];

    my ($lt, $lv, $ht, $hv) = @{ $rules{$bot_id} };

    # PART 1
    if ($lo == 17 && $hi == 61) {
        $p1 = $bot_id;
    }

    # LOW
    if ($lt eq "bot") {
        push @{ $bots{$lv} }, $lo;
        push @q, $lv if @{ $bots{$lv} } == 2;
    } else {
        $outputs{$lv} = $lo;
    }

    # HIGH
    if ($ht eq "bot") {
        push @{ $bots{$hv} }, $hi;
        push @q, $hv if @{ $bots{$hv} } == 2;
    } else {
        $outputs{$hv} = $hi;
    }
}

# ----------------------------
# PART 2
# ----------------------------
my $p2 = $outputs{0} * $outputs{1} * $outputs{2};

print "2016 day10: pl_ans_1: $p1\n";
print "2016 day10: pl_ans_2: $p2\n";
