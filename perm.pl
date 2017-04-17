#use warnings;
use strict;
my $usage = "perl perm.pl <num_cond1> <num_cond2> <outputfile>

-num_permutations <n> 

";

if (@ARGV<3){
    die $usage;
}
my @num_reps;
my $num_conds = 2;
$num_reps[0] = $ARGV[0];
$num_reps[1] = $ARGV[1];
my $total = $num_reps[0]+$num_reps[1];
my $num_perms = Binomial($total,$num_reps[0]); #can change this number to get a random set instead of full list
$num_perms += 0.01;
$num_perms = int($num_perms);
for(my $i=3;$i<@ARGV;$i++){
    my $opt_found = "false";
    if ($ARGV[$i] eq '-num_permutations'){
	$opt_found = "true";
	$num_perms = $ARGV[$i+1];
	$i++;
    }
    if ($opt_found eq "false"){
	die "option \"$ARGV[$i]\" was not recognized.\n";
    }
}
my $paired = 0;
my $design = "A";

my $perms_ref = InitializePermuationArray($num_conds, \@num_reps, $num_perms, $paired, $design);
my @permutations = @{$perms_ref};
open(OUT, ">$ARGV[2]");
PrintPermutationMatrix($num_conds, $perms_ref, $design);
close(OUT);

sub InitializePermuationArray {
    my ($num_conds, $num_reps_ref, $num_perms, $paired, $design) = @_;
    my @num_reps = @{$num_reps_ref};

    my @perm_array;
    my $perm_array_ref;
    if(!($design eq "D")) {
	for(my $i=1; $i<$num_conds; $i++) {
	    if($paired == 0) {
		my $size_of_group1 = $num_reps[0];
		my $size_of_group2 = $num_reps[$i];
		my $sum = $size_of_group1 + $size_of_group2;
		my $n;
		if($sum-$size_of_group1 > $size_of_group1) {
		    $n = $size_of_group1;
		}
		else {
		    $n = $sum-$size_of_group1;
		}
		my $m = $sum;
		my $num_all_perms=Binomial($m,$n);
		$num_all_perms += 0.01;
		$num_all_perms = int($num_all_perms);
		if($num_all_perms < $num_perms+25) {
		    $perm_array_ref = GetAllSubsetsOfFixedSize($sum, $size_of_group1);
		}
		else {
		    $perm_array_ref = GetRandomSubsetsOfFixedSize($sum, $size_of_group1, $num_perms);
		}
		@{$perm_array[$i]} = @{$perm_array_ref};
	    }
	    else {
		my $size_of_group = $num_reps[0];
		my $number_subsets = 2**$size_of_group;
		my $temp_array_ref;
		if($number_subsets < $num_perms+25) {
		    $temp_array_ref = ListAllSubsets($size_of_group);
		}
		else {
		    $temp_array_ref = GetRandomSubsets($size_of_group, $num_perms);
		}
		my @temp_array = @{$temp_array_ref};
		my $n = @temp_array;
		for(my $p=0; $p<$n; $p++) {
		    for(my $j=0; $j<$num_reps[0]; $j++) {
			$perm_array[$i][$p][$j] = $temp_array[$p][$j];
			$perm_array[$i][$p][$j+$num_reps[0]] = 1-$temp_array[$p][$j];
			if($p==0) {
			    $perm_array[$i][$p][$j] = 1;
			    $perm_array[$i][$p][$j+$num_reps[0]] = 0;
			}
		    }
		}
	    }
	}
    }
    else {
	for(my $i=0; $i<$num_conds; $i++) {
	    my $size_of_group = $num_reps[$i];
	    my $number_subsets = 2**$size_of_group;
	    if($number_subsets < $num_perms+25) {
		$perm_array_ref = ListAllSubsets($size_of_group);
	    }
	    else {
		$perm_array_ref = GetRandomSubsets($size_of_group, $num_perms);
	    }
	    @{$perm_array[$i]} = @{$perm_array_ref};
	}
    }
    return \@perm_array;
}


sub ListAllSubsets {
    my($size_of_set) = @_;
    my @perm_array;
    my $num_subsets = 2**$size_of_set;

    for(my $i=0; $i<$num_subsets; $i++) {
	for(my $j=0; $j<$size_of_set; $j++) {
	    $perm_array[$i][$j] = 0;
	}
    }
    my @counter;
    my $perm_counter = 0;
    for(my $subsetsize=1; $subsetsize < $size_of_set+1; $subsetsize++) {
	for(my $i=1; $i<$subsetsize+1; $i++) {
	    $counter[$i]=$i;
	}
	my $flag=0;
	while($flag==0) {
	    $perm_array[$perm_counter][$counter[1]-1]++;
	    for(my $p=2; $p<$subsetsize+1; $p++) {
		$perm_array[$perm_counter][$counter[$p]-1]++;
	    }
	    $perm_counter++;
	    my $j=$size_of_set;
	    my $jj=$subsetsize;
	    while(($counter[$jj]==$j) && ($j>0)) {
		$jj--;
		$j--;
	    }
	    if($jj==0) {
		$flag=1;
	    }
	    if($jj>0) {
		$counter[$jj]++;
		my $k=1;
		for(my $i=$jj+1; $i<$subsetsize+1; $i++) {
		    $counter[$i]=$counter[$jj]+$k;
		    $k++;
		}
	    }
	}
    }

    return \@perm_array;
}

sub GetRandomSubsets {
    my ($size_of_set, $num_subsets) = @_;
    my @subset_array;

    for(my $i=0; $i<$num_subsets; $i++) {
	for(my $j=0; $j<$size_of_set; $j++) {
	    $subset_array[$i][$j] = 0;
	}
    }
    for(my $i=1; $i<$num_subsets; $i++) {
	for(my $j=0; $j<$size_of_set; $j++) {
	    my $flip = int(rand(2));
	    if($flip == 1) {
		$subset_array[$i][$j]++;
	    }
	}
    }
    return \@subset_array;
}
sub GetRandomSubsetsOfFixedSize {

    my ($size_of_set, $size_of_subset, $num_subsets) = @_;

    my @subset_array;
    my $counter=0;
    my $subset_ref;
    for(my $j=0; $j<$size_of_subset; $j++) {
	$subset_array[0][$j]=1;
    }
    for(my $j=$size_of_subset; $j<$size_of_set; $j++) {
	$subset_array[0][$j]=0;
    }
    for(my $i=1; $i<$num_subsets; $i++) {
	$subset_ref = ChooseRand($size_of_subset, $size_of_set);
	my @subset = @{$subset_ref};
	for(my $j=0; $j<$size_of_set; $j++) {
	    $subset_array[$i][$j]=0;
	}
	my $n = @subset;
	for(my $j=0; $j<$n; $j++) {
	    $subset_array[$i][$subset[$j]-1]++;
	}
    }
    return \@subset_array;
}

sub ChooseRand {
    my ($subsetsize, $groupsize)=@_;
    my $flag=0;
    my $x;
    my @subset;

    for(my $i=0; $i<$subsetsize; $i++) {
	$flag=0;
	while($flag==0) {
	    $flag=1;
	    $x=int(rand($groupsize))+1;
	    for(my $j=0; $j<$i; $j++) {
		if($x==$subset[$j]) {
		    $flag=0;
		}
	    }
	}
	$subset[$i]=$x;
    }
    return \@subset;
}


sub Binomial {
    my ($m, $n) = @_;
    my $total=1;
    for(my $j=0; $j<$n; $j++) {
	$total = $total * ($m-$j)/($n-$j);
    }
    return $total;
}

sub GetAllSubsetsOfFixedSize {

    my ($size_of_set, $size_of_subset) = @_;

    my @subset_array;
    my @counter;

    for(my $i=1; $i<$size_of_subset+1; $i++) {
	$counter[$i]=$i;
    }
    my $flag=0;
    my $subset_counter = 0;
    my $num_subs = Binomial($size_of_set, $size_of_subset);
    $num_subs += 0.01;
    $num_subs = int($num_subs);
    for(my $i=0; $i<$num_subs; $i++) {
	for(my $j=0; $j<$size_of_set; $j++) {
	    $subset_array[$i][$j]=0;
	}
    }
    while($flag==0) {
	$subset_array[$subset_counter][$counter[1]-1]++;
	for(my $p=2; $p<$size_of_subset+1; $p++) {
	    $subset_array[$subset_counter][$counter[$p]-1]++;
	}
	my $j=$size_of_set;
	my $jj=$size_of_subset;
	while(($counter[$jj]==$j) && ($j>0)) {
	    $jj--;
	    $j--;
	}
	if($jj==0) {
	    $flag=1;
	}
	if($jj>0) {
	    $counter[$jj]++;
	    my $k=1;
	    for(my $i=$jj+1; $i<$size_of_subset+1; $i++) {
		$counter[$i]=$counter[$jj]+$k;
		$k++;
	    }
	}
	$subset_counter++;
    }

    return \@subset_array;
}

sub PrintPermutationMatrix {

# this subroutine prints the matrix of permutations for DEBUG

    my ($num_conds, $perm_matrix_ref, $design) = @_;
    my @permutations = @{$perm_matrix_ref};

    if(!($design eq "D")) {
	my $index = 1;
	for(my $i=1; $i<$num_conds; $i++) {
	    #print OUT "---- condition $i ----\n";
	    my $n = @{$permutations[$i]};
	    for(my $j=0; $j<$n; $j++) {
		my $cnt0 = 1;
		my $cnt1 = 1;
		my $m = @{$permutations[$i][$j]};
		my $cond = $permutations[$i][$j][0];
		my $to_print = "c$cond";
		if ($cond == 0){
		    $to_print .= "r"."$cnt0";
		    $cnt0++;
		}
		if ($cond == 1){
		    $to_print .= "r"."$cnt1";
		    $cnt1++;
		}
		#print OUT "$index\t$permutations[$i][$j][0]";
		my $new_print = $to_print;
		$new_print =~ s/c1/c2/g;
		$new_print =~ s/c0/c1/g;
		$new_print =~ s/c2/c0/g;
		print OUT "$ARGV[0]vs$ARGV[1].$index\t$new_print";
#		print OUT "$ARGV[0]vs$ARGV[1].$index\t$to_print";
		for(my $k=1; $k<$m; $k++) {
		    my $cond = $permutations[$i][$j][$k];
		    my $to_print = "c$cond";
		    if ($cond == 0){
			$to_print .= "r"."$cnt0";
			$cnt0++;
		    }
		    if ($cond == 1){
			$to_print .= "r"."$cnt1";
			$cnt1++;
		    }
		    #print OUT "\t$permutations[$i][$j][$k]";
		    $new_print = $to_print;
		    $new_print =~ s/c1/c2/g;
		    $new_print =~ s/c0/c1/g;
		    $new_print =~ s/c2/c0/g;
		    print OUT "\t$new_print";
		    #print OUT "\t$to_print";
		}
		print OUT "\n";
		$index++;
	    }
	}
    }
    else {
	for(my $i=0; $i<$num_conds; $i++) {
	    #print OUT "---- condition $i ----\n";
	    my $n = @{$permutations[$i]};
	    for(my $j=0; $j<$n; $j++) {
		my $m = @{$permutations[$i][$j]};
		print OUT "$permutations[$i][$j][0]";
		for(my $k=1; $k<$m; $k++) {
		    print OUT ",$permutations[$i][$j][$k]";
		}
		print OUT "\n";
	    }
	}
    }
}
