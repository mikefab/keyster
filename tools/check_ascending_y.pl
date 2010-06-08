$book = $ARGV[0];
opendir(DIR,"../books/$book/xml")|| die "../can't open books/$book/xml: $!";
foreach $file(sort readdir DIR){	
  next if $file=~/^\./;
%cols=undef;
  open(F,"../books/$book/xml/$file")||die "can't open xml/$file";
	%hash=undef;
	for($i=1;$i<100;$i++){	
		@$i=undef;
	}

	while($line=<F>){

###check for repeat x y values
	  $y=undef;$col=undef; $row=undef;
	  $col=$2 if $line=~/(col=")(.+?)(")/;
	  $row=$2 if $line=~/(row=")(.+?)(")/;
		$cols{$col}++;
	  $y=$2 if $line=~/(y1=")(.+?)(")/;
		$hash{"$col$y"}=$row;
		push(@$col,$y);
	}
 close F;

	foreach $col(sort keys%cols){
		$c=0;
	  foreach $y(@$col){
			print qq($file $hash{"$col$y"} $hash{"$col@$col[$c-1]"}* $col - $y - @$col[$c-1]\n) if $y<@$col[$c-1] && $y;
			$c++;
		}
	}

	


  
}
