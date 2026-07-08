use strict;
use warnings;


my $file = shift;


open(my $fh,"<",$file) or die $!;

my $text = do {
    local $/;
    <$fh>;
};

close($fh);



# ------------------------------------------------------------
# Parse input
# ------------------------------------------------------------

my ($rules_text,$messages_text) =
    split(/\n\n/,$text);


my %rules;


foreach my $line (split(/\n/,$rules_text)) {


    my ($k,$v)=split(/: /,$line,2);


    $rules{$k}=$v;

}



my @messages =
    split(/\n/,$messages_text);



# ------------------------------------------------------------
# Build regex
# ------------------------------------------------------------

sub build_regex {


    my ($rules,$r,$cache)=@_;


    return $cache->{$r}
        if exists $cache->{$r};



    my $rule=$rules->{$r};



    # literal character

    if ($rule =~ /"/) {

        $rule =~ s/"//g;

        $cache->{$r}=$rule;

        return $rule;

    }



    my @parts =
        split(/ \| /,$rule);



    my @out;


    foreach my $p (@parts) {


        my @tokens =
            split(/ /,$p);


        my $seq="";


        foreach my $t (@tokens) {

            $seq .=
                build_regex($rules,$t,$cache);

        }


        push @out,$seq;

    }



    my $result =
        "(" . join("|",@out) . ")";


    $cache->{$r}=$result;


    return $result;

}



# ------------------------------------------------------------
# Solve Part 1
# ------------------------------------------------------------

my %cache;


my $built =
    build_regex(\%rules,"0",\%cache);



# IMPORTANT:
# Perl needs \$ for regex end anchor

my $pattern =
    "^" . $built . "\$";


my $regex = qr/$pattern/;



my $answer=0;


foreach my $msg (@messages) {


    $answer++
        if $msg =~ $regex;

}



print "2020 day19: pl_ans_1: $answer\n";

sub pp2conor {

#open(my $fh,"<",$file) or die $!;
#my $file = shift;


#open(my $fh,"<",$file) or die $!;

#my $text = do {
#    local $/;
#    <$fh>;
#};

#close($fh);



# ------------------------------------------------------------
# Parse
# ------------------------------------------------------------

my ($rules_text,$messages_text) =
    split(/\n\n/,$text);


my %rules;


foreach my $line (split(/\n/,$rules_text)) {

    my ($k,$v)=split(/: /,$line,2);

    $rules{$k}=$v;

}


my @messages =
    split(/\n/,$messages_text);



# ------------------------------------------------------------
# Build regex Part 2
# ------------------------------------------------------------

sub build_part2 {


    my ($rules,$r,$cache)=@_;


    return $cache->{$r}
        if exists $cache->{$r};



    # Rule 8:
    # 8: 42 | 42 8
    # becomes 42+

    if ($r eq "8") {


        my $r42 =
            build_part2($rules,"42",$cache);


        my $result =
            "(" . $r42 . "+)";


        $cache->{$r}=$result;


        return $result;

    }



    # Rule 11:
    # 42 31 | 42 11 31
    #
    # bounded:
    # 42{1}31{1}
    # 42{2}31{2}
    # ...

    if ($r eq "11") {


        my $r42 =
            build_part2($rules,"42",$cache);


        my $r31 =
            build_part2($rules,"31",$cache);



        my @parts;


        for my $i (1..5) {


            push @parts,
                "(" .
                $r42 . "{" . $i . "}" .
                $r31 . "{" . $i . "}" .
                ")";

        }



        my $result =
            "(" . join("|",@parts) . ")";


        $cache->{$r}=$result;


        return $result;

    }



    my $rule=$rules->{$r};



    # literal

    if ($rule =~ /"/) {


        $rule =~ s/"//g;


        $cache->{$r}=$rule;


        return $rule;

    }



    my @parts =
        split(/ \| /,$rule);



    my @out;


    foreach my $p (@parts) {


        my @tokens =
            split(/ /,$p);


        my $seq="";


        foreach my $t (@tokens) {


            $seq .=
                build_part2($rules,$t,$cache);

        }


        push @out,$seq;

    }



    my $result =
        "(" . join("|",@out) . ")";


    $cache->{$r}=$result;


    return $result;

}



# ------------------------------------------------------------
# Solve
# ------------------------------------------------------------

my %cache;


my $built =
    build_part2(\%rules,"0",\%cache);



# Perl regex end anchor needs escaped $

my $pattern =
    "^" . $built . "\$";


my $regex = qr/$pattern/;



my $answer=0;


foreach my $msg (@messages) {


    $answer++
        if $msg =~ $regex;

}



print "2020 day19: pl_ans_2: $answer\n";
}
pp2conor($text)
