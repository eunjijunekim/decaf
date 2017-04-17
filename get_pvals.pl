use warnings;
use strict;
my $usage = "perl pvals.pl <loc> <original> <sampleinfo>

\"p-values.txt\" outputs 

";
if (@ARGV<3){
    die $usage;
}

my $loc = $ARGV[0];
my $goal = $ARGV[1];
my $sampleinfo = $ARGV[2];

open(IN, $sampleinfo) or die "ERROR: cannot open $sampleinfo\n";
my $h = <IN>;
chomp($h);
my %SCOL;
my $c_cnt = 0;
while(my $line = <IN>){
    chomp($line);
    my ($sample, $cond) = split(/\t/,$line);
    $SCOL{$c_cnt} = "$cond.$sample";
    $c_cnt++;
}
close(IN);

my $pvals = "$loc/p-values.txt";
open(OUT, ">$pvals");
my @conf = (0.5, 0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95);
my $goal_div = &getDiv($goal);
my $len = length($goal_div);
print OUT "-" x $len;
print OUT "\n";
print OUT "$goal_div\n";
print OUT "-" x $len;
print OUT "\n";
print OUT "fdr\tp-val\tOptimalDiv\n";

foreach my $f (@conf){
    my $final = "$loc/final.$f.txt";
    my $lc = `wc -l $final`;
    chomp($lc);
    my @c = split(" ", $lc);
    my $total = $c[0];
    my $x = `grep -w $goal $final`;
    chomp($x);
    my @a = split(/\t/, $x);
    my $unperm_cnt = $a[1];
    my $rank = 0;
    my $max = 0;
    my $maxstring="";
    open(FIN, $final);
    while(my $line = <FIN>){
	chomp($line);
	my @a = split(" ", $line);
	my $cnt = $a[1];
	if ($cnt >= $unperm_cnt){
	    $rank++;
	}
	if ($cnt > $max){
	    $max = $cnt;
	    $maxstring = $a[0];
	}
    }
    close(FIN);
    my $p = ($rank/$total);
    $p = sprintf ("%.4f", $p);
    my $odiv = &getDiv($maxstring);
    my $fdr = 1-$f;
    print OUT "$fdr\t$p\t$odiv\n";
}
close(OUT);    


sub getDiv {
    my ($string) = @_;
    my $colN = 0;
    my %CONDS;
    foreach my $cond (split //, $string){
	my $sampleid = $SCOL{$colN};
	$colN++;
	if (exists $CONDS{$cond}){
	    $CONDS{$cond} .= ",$sampleid";
	}
	else{
	    $CONDS{$cond} = $sampleid;
	}
    }
    return "[".$CONDS{0}."],[".$CONDS{1}."]";

}

