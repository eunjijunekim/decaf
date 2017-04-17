use warnings;
use strict;

my $usage = "perl parse_PAGE_txtoutput.pl <datafile> <all combinations file>

";

if (@ARGV<2){
    die $usage;
}
my $x = 0.5;
print "conf";
my %CF;

for (my $i=0;$i<10;$i++){
    $CF{$x} = 1;
    print "\t$x";
    $x += 0.05;
}
print "\n";

my @a = split("/", $ARGV[1]);
my $s = @a;
my $y = $a[@a-1];
my $type = $y;
$type =~ s/perm.//;
$type =~ s/.txt//;

open(IN, $ARGV[1]) or die "cannot find file $ARGV[1]\n";
#my $h = <IN>;
while(my $line = <IN>){
    chomp($line);
    my @a = split(/\t/,$line);
    my $index = $a[0];
    my $newout = $ARGV[0];
    $newout =~ s/.txt$/.$index.OUTPUT.txt/;
    my $x = 0.5;
    print "$index";
    my %CF_CNT;
    foreach my $c (keys %CF){
	$CF_CNT{$c} = 0;
    }
    open (IN2, $newout) or die "cannot open $newout\n";
    while(my $nline = <IN2>){
	chomp($nline);
	if ($nline =~ /^$/){
	    next;
	}
	my ($cfl, $up, $down) = split(/\t/,$nline);
	my $cf_cnt = 0;
	if (exists $CF{$cfl}){
	    $CF{$cfl} = $up+$down;
	    $CF_CNT{$cfl}++;
	}
    }
    close(IN2);
    foreach my $c (keys %CF_CNT){
	if ($CF_CNT{$c} ne 1){
	    die "ERROR: check your inputfile1\n";
	}
    }
    foreach my $cfl (sort keys %CF){
	print "\t$CF{$cfl}";
    }
    print "\n";
}
close(IN);
