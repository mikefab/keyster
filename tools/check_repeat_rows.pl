$book = $ARGV[0];
opendir(DIR,"../books/$book/xml")|| die "../can't open books/$book/xml: $!";
foreach $file(sort readdir DIR){	
  next if $file=~/^\./;
  open(F,"../books/$book/xml/$file")||die "can't open xml/$file";
	%hash=undef;
	%col=undef;
for($i=1;$i<10;$i++){	
	@$i=undef;
}
	while($line=<F>){

###Check for repeat row numbers
		$row=undef;
		$row=$2 if $line=~/(row=")(.+?)(")/;
		$col=$2 if $line=~/(col=")(.+?)(")/;
		$col{$col}++ if $col;
	  push(@$col,$row) if $row;
	}
 close F;




	foreach $col(keys%col){
		if($col){
#			print "$file $col @$col\n";
    %rows=undef;
		foreach $row(@$col){
			$rows{$row}++;
		}
		foreach $row(sort{$a<=>$b}	 keys%rows){
			print "$file $row $rows{$row}\n" if $row && $rows{$row}>1;
		}
}
  }
	

  
}
