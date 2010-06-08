
$book = $ARGV[0];
opendir(DIR,"../books/$book/xml")|| die "../can't open books/$book/xml: $!";
foreach $file(sort readdir DIR){	

  next if $file=~/^\./;
	@a=undef;
  $cols=undef;
  $rows=undef;
  open(F,"../books/$book/xml/$file")||die "can't open xml/$file";
	$c=1;
	$r=1;
	while($line=<F>){
		$num=undef;
		$cols=$2 if $line=~/(cols=")(.+?)(")/;
		$rows=$2 if $line=~/(rows=")(.+?)(")/;
		$num=$2 if $line=~/(num=")(.+?)(")/;
		if($num){
			$col=undef;
			$col=int($num/$rows);
			$c++ if $r==($rows+1);
		  $r=1 if $r==($rows+1);
			$line=~s/row=".+?"/row="$r"/;
			$line=~s/col=".+?"/col="$c"/;
		#	print "$line";
			$r++;
		}
		push(@a,$line);

  }  
	open(F,">../books/$book/xml2/$file")||die "can't open $file: $!";
	$a[5]=~s/>  </>\n  </;
	print F @a;
	close F;

}	
