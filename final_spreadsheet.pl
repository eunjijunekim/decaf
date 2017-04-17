use warnings;
use strict;

my $usg = "perl final_spreadsheet.pl <num_samples> <scoresfile>

";


if (@ARGV<2){
    die $usg;
}

my $ns = $ARGV[0];
my $file = $ARGV[1];

my $total = 2**$ns;
for(my$i=1;$i<=$total;$i++){
    my $binary = sprintf ("%b",$i-1);
    my $l = length($binary);
    if ($l < $ns){
	my $z = $ns - $l;
	my $zeros = "";
	for(my $j=0;$j<$z;$j++){
	    $zeros .= "0";
	}
	$binary = $zeros . $binary;
    }
    my $x = `grep -w $binary $file | wc -l`;
    if ($x == 1){
	my $y = `grep -w $binary $file`;
	print $y;
    }
    else{
	print "$binary\t0\n";
    }
}
