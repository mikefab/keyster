$book=$ARGV[0];

opendir(DIR,"../books/$book/pre_xml")||die "can't open: $!";
for(sort readdir DIR){
	next if $_=~/^\./;
	open(F,"../books/$book/pre_xml/$_")||print "can't open: $! ";;
$c=1;
	while($line=<F>){
		$line=~s/\n//g;
		$line=~s/\r//g;
$s=undef;
		@t=split(/\t/,$line);
		$s= "$_ $c $#t: ";
		foreach $cell(@t){
			$cell=~s/\n//g;
			$s.= "-$cell-";
		}
		$s.="\n";
print $s if $#t==3;
$c++;
	}
	close F;
}
