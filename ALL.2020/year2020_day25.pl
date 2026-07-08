use strict;
use warnings;


my $MOD = 20201227;


my $file = shift;


open(my $fh,"<",$file) or die $!;


my @lines;

while (<$fh>) {

    chomp;

    push @lines,int($_)
        if $_ ne "";

}

close($fh);



# ------------------------------------------------------------
# Transform
# ------------------------------------------------------------

sub transform {

    my ($subject,$loop_size)=@_;


    my $value=1;


    for (1..$loop_size) {

        $value = ($value * $subject) % $MOD;

    }


    return $value;

}



# ------------------------------------------------------------
# Find loop size
# ------------------------------------------------------------

sub find_loop_size {


    my ($public_key)=@_;


    my $value=1;

    my $loop=0;

    my $subject=7;



    while ($value != $public_key) {


        $value =
            ($value * $subject) % $MOD;


        $loop++;

    }


    return $loop;

}



# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

my $card_public=$lines[0];
my $door_public=$lines[1];


my $card_loop=find_loop_size($card_public);


my $ans=transform(
    $door_public,
    $card_loop
);



print "2020 day25: pl_ans_1: $ans\n";
