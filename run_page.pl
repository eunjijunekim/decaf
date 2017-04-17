use warnings;
use strict;
use Cwd 'abs_path';
my $usage = "perl run_page.pl 

1. <channel> Are the arrays 1-Channel or 2-Channel arrays?  (enter \"1\" or \"2\") 
2. <paired> Are the arrays paired? (enter Y or N)
3. <logtransformed> Is the data log transformed? (enter Y or N)
4. <datafile> Enter the name of the datafile
5. <conflevel> Please enter the level confidence (a number between 0 and 1)
6. <non-missing> Please enter the min number of non-missing values there must be in each condition 
   for a row to not be ignored (a positive integer greater than 1)
7. <stat> What statistic would you like to use? The T-statistic (enter 0) The Ratio with means (enter 1)
8. <logtransformeddata> Do you want to run algorithm on the log transformed data? (Y or N)
9. <number of permutations> binom

";

if (@ARGV<9){
    die $usage;
}

my $path = abs_path($0);
$path =~ s/run_page.pl//;
my $page = "$path/PaGE_5.1.7.pl";
unless (-e $ARGV[3]){
    die "cannot find file $ARGV[3]";
}

my $n_channel = $ARGV[0];
my $paired = $ARGV[1];
my $log_1 = $ARGV[2];
my $infile = $ARGV[3];
my $outfile = $infile;
$outfile =~ s/.txt$/.OUTPUT/;
my $conflev = $ARGV[4];
my $nonmiss = $ARGV[5];
my $stat = $ARGV[6];
my $log_2 = $ARGV[7];
my $nb = $ARGV[8];
my $options = "--infile $ARGV[3] --outfile $outfile --num_channels $n_channel --level_confidence $conflev --min_presence $nonmiss --output_text"; #--silent_mode
if ($paired eq "Y"){
    $options .= " --paired";
}
else{
    $options .= " --unpaired";
}
if ($log_1 eq "Y"){
    $options .= " --data_is_logged";
}
else{
    $options .= " --data_not_logged";
}
if ($stat eq "0"){
    $options .= " --tstat";
}
else{
    $options .= " --means";
}
if ($log_2 eq "Y"){
    $options .= " --use_logged_data";    
}
else{
    $options .= " --use_unlogged_data";    
}
if ($nb > 200){
    $nb++;
    $options .= " --num_permutations $nb";
}
#print "perl $page $options\n";
`perl $page $options`;
print "got here\n";
