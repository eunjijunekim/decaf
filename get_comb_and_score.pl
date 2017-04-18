use warnings;
use strict;
use Cwd 'abs_path';
my $usage = "perl get_comb_and_score.pl <file of all index> <loc> <numberofsamples>

[options]
 By default:
 \"Exhaustive Mode\" is used when <total_num_sample> <= 10 and
 \"P-value Mode\" is used when <total_num_sample> > 10.

 You can force DECAF to use Exhaustive Mode even if total number of samples > 10,
 by using this option:
 -E : Exhaustive Mode

 -h : display usage


";

if (@ARGV<3){
    die $usage;
}


for(my $i=0;$i<@ARGV;$i++){
    if ($ARGV[$i] eq '-h'){
        die $usage;
    }
}
my $cnt = 0;
my $E_mode = "false";
my $P_mode = "false";
for(my $i=3;$i<@ARGV;$i++){
    my $option_f = "false";
    if ($ARGV[$i] eq '-h'){
        $option_f = "true";
        die $usage;
    }
    if ($ARGV[$i] eq '-E'){
        $option_f = "true";
        $cnt++;
        $E_mode = "true";
    }
    if ($option_f eq "false"){
        die "option \"$ARGV[$i]\" was not recognized.\n";
    }
}

my $path = abs_path($0);
$path =~ s/get_comb_and_score.pl//;
my $index = $ARGV[0];
my $loc = $ARGV[1];
my $ns = $ARGV[2];

my $default = "true";
if ($cnt == 1){
    $default = "false";
}
if ($default eq 'true'){
    if ($ns > 10){
        $P_mode = "true";
    }
    else{
        $E_mode = "true";
    }
}

my $p;
my %PAT;
my @fdr = (0.5, 0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95);
foreach my $f (@fdr){
    my $count = "$loc/counts.$f.txt";
    my $final = "$loc/final.$f.txt";
    open(OUT, ">$count");
    my %SEEN = ();
    open(ID, $index) or die "cannot open $index\n";
    %PAT = ();
    while(my $line = <ID>){
	chomp($line);
	open(IX, $line) or die "cannot open $line\n";
	while(my $line2 = <IX>){
	    my @a = split(/\t/,$line2);
	    my $id = $a[0];
	    my $pattern="";
	    for(my$i=1;$i<@a;$i++){
		my $x = $a[$i];
		$x =~ s/c//;
		$x =~ s/r.*$//;
		$pattern .= $x;
	    }
	    $PAT{$id} = $pattern;
	}
	close(IX);
        my @sx = split("/",$line);
	my $sum = $sx[@sx-1];
	$sum =~ s/perm./all_perm./;
        $sum = "$loc/$sum";
	open(SUM, $sum) or die "cannot open $sum\n";
	my $col = 0;
	my $h = <SUM>;
	my @a = split(/\t/,$h);
	for(my $i=1;$i<@a;$i++){
	    if ($f == $a[$i]){
		$col = $i;
	    }
	}
	while(my $line = <SUM>){
	    chomp($line);
	    my @x = split(/\t/,$line);
	    my $id = $x[0];
	    my $score = $x[$col];
	    my $check = $PAT{$id};
	    chomp($check);
	    unless (exists $SEEN{$check}){
	    	print OUT "$check\t$score\n";
		$SEEN{$check} = 1;
	    }
            if ($E_mode eq "true"){
                my $zeros = $check =~ tr/0//;
                my $ones = $check =~ tr/1//;
                unless ($zeros == $ones){
                    my $newid = $check;
                    $newid =~ s/1/2/g;
                    $newid =~ s/0/1/g;
                    $newid =~ s/2/0/g;
		    unless (exists $SEEN{$check}){
	            	print OUT "$newid\t$score\n";
		    }
                }
            }
	}
    }
    close(SUM);
    close(OUT);
    if ($E_mode eq "true"){
        $p = `perl $path/final_spreadsheet.pl $ns $count > $final`;
    }
    if ($P_mode eq "true"){
        $p = `mv $count $final`;
    }    
}
close(ID);
