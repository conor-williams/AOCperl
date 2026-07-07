use strict;
use warnings;


sub parse {

    my (@lines)=@_;

    my ($start_state) =
        $lines[0] =~ /Begin in state ([A-Z])/;

    my ($steps) =
        $lines[1] =~ /(\d+) steps/;


    my %states;

    my $i = 3;

    while ($i < @lines) {

        if ($lines[$i] !~ /^In state/) {
            $i++;
            next;
        }

        my ($state) = $lines[$i] =~ /state ([A-Z])/;


        my ($write0) =
            $lines[$i+2] =~ /(\d)/;

        my $move0 =
            ($lines[$i+3] =~ /right/) ? 1 : -1;

        my ($next0) =
            $lines[$i+4] =~ /state ([A-Z])/;


        my ($write1) =
            $lines[$i+6] =~ /(\d)/;

        my $move1 =
            ($lines[$i+7] =~ /right/) ? 1 : -1;

        my ($next1) =
            $lines[$i+8] =~ /state ([A-Z])/;


        $states{$state} = {
            0 => [$write0,$move0,$next0],
            1 => [$write1,$move1,$next1]
        };


        $i += 9;
    }


    return ($start_state,$steps,\%states);
}


sub run {

    my ($start_state,$steps,$states)=@_;

    my %tape;

    my $cursor = 0;
    my $state = $start_state;


    for (1 .. $steps) {

        my $val = exists $tape{$cursor}
            ? $tape{$cursor}
            : 0;


        my ($write,$move,$next) =
            @{$states->{$state}->{$val}};


        $tape{$cursor} = $write;

        $cursor += $move;

        $state = $next;
    }


    my $checksum = 0;

    for my $v (values %tape) {
        $checksum += $v;
    }

    return $checksum;
}


sub main {

    open(my $fh,"<",$ARGV[0]) or die $!;

    my @lines = <$fh>;
    chomp @lines;

    my ($start_state,$steps,$states)=parse(@lines);

    print "2017 day25: pl_ans_1: ",
          run($start_state,$steps,$states),
          "\n";
}

main();
