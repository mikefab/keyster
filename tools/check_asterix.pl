$book = $ARGV[0];
opendir(DIR,"../books/$book/xml")|| die "../can't open books/$book/xml: $!";
for(sort readdir DIR){	
  next if $_=~/^\./;

  open(F,"../books/$book/xml/$_")||die "can't open xml/$_";
	while($line=<F>){
		$num=undef;
		$num=$2 if ($line=~/(num=")(.+?)(")/);
		print "* $_ $num\n" if $line=~/\*/ ;
		print "^ $_ $num\n" if $line=~/\^/;
		print "ff $_ $num\n" if $line=~/\f/;
	}
}
