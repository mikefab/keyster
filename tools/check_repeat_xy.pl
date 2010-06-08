$book = $ARGV[0];
opendir(DIR,"../books/$book/xml")|| die "../can't open books/$book/xml: $!";
foreach $file(sort readdir DIR){	
  next if $file=~/^\./;
  open(F,"../books/$book/xml/$file")||die "can't open xml/$file";
	%hash=undef;


	while($line=<F>){

###check for repeat x y values
	  $x1=undef; $y1=undef;
	  $x1=$2 if $line=~/(x1=")(.+?)(")/;
	  $y1=$2 if $line=~/(y1=")(.+?)(")/;
		$hash{"$x1-$y1"}++ if $x1;

###Check for repeat row numbers
		$row=undef;
		$row=$2 if $line=~/(row=")(.+?)(")/;
		$col=$2 if $line=~/(col=")(.+?)(")/;
		$col{$col}++ if $col;
	  push(@$col,$row) if $row;
	}
 close F;


	for(keys%hash){
		print "$file $_ $hash{$_}\n" if $hash{$_} >1;
  }

  
}
