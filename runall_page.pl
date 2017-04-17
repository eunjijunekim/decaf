use warnings;
use strict;
use Cwd 'abs_path';

my $usage = "perl runall_page.pl <count table> <loc> <num_cond1> <num_cond2>

[options]
 By default:
 \"Exhaustive Mode\" is used when <total_num_sample> <= 10 and
 \"P-value Mode\" is used when <total_num_sample> > 10.

 You can force DECAF to use Exhaustive Mode even if total number of samples > 10,
 by using this option:
 -E : Exhaustive Mode
 -h : display usage


";
for(my $i=0;$i<@ARGV;$i++){
    if ($ARGV[$i] eq '-h'){
        die $usage;
    }
}
if (@ARGV<4){
    die $usage;
}
my $cnt = 0;
my $E_mode = "false";
my $P_mode = "false";
for(my $i=4;$i<@ARGV;$i++){
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

my $data = $ARGV[0];
my @fn = split("/", $data);
my $filename = $fn[@fn-1];
my $LOC = $ARGV[1];
my $n0 = $ARGV[2];
my $n1 = $ARGV[3];
my $log = "$LOC/logs";
unless (-d $log){
    `mkdir $log`;
}
my $total = $n0+$n1;
my $default = "true";
if ($cnt == 1){
    $default = "false";
}
if ($default eq 'true'){
    if ($total > 10){
        $P_mode = "true";
    }
    else{
        $E_mode = "true";
    }
}

my $path = abs_path($0);
$path =~ s/runall_page.pl//;
my $type = $n0 . "vs" .$n1;
my $index = "$LOC/perm.$type.txt";
my $nb = 200;
if ($E_mode eq "true"){
    $nb = &Binomial($total,$n0);
    $nb += 0.01;
    $nb = int($nb);
}

my @threads;
open(IN, $index) or die "cannot open $index\n";
#my $hi = <IN>;
while(my $line = <IN>){
    chomp($line);
    my @a = split(/\t/,$line);
    my $id = $a[0];
    my $jobname = "runpage.$id";
    my $new =" $LOC/$filename";
    $new =~ s/.txt$/.$id.txt/;
    #write temp files and run page
    open(OUT, ">$new") or die "cannot open $new\n";
    print OUT "$line\n";
    close(OUT);
    `cat $data >> $new`;
    `echo "perl $path/run_page.pl 1 N N $new 0.5 2 0 N $nb" | bsub -J $jobname -o $log/$jobname.out -e $log/$jobname.err`;
    sleep(2);
}

close(IN);

sub Binomial {
    my ($m, $n) = @_;
    my $total=1;
    for(my $j=0; $j<$n; $j++) {
        $total = $total * ($m-$j)/($n-$j);
    }
    return $total;
}
