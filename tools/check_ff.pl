$book = $ARGV[0];
opendir(DIR,"../books/$book/pre_xml")|| die "../can't open books/$book/xml: $!";
$c=1;
for(sort readdir DIR){	
  next if $_=~/^\./;

  open(F,"../books/$book/pre_xml/$_")||die "can't open xml/$_";
	undef $/;
	$data=<F>;
	close F;
	print "$_ $c\n" if $data=~/\f/;
	$c++ if $data=~/\f/;
}
print "\n\n--  $c --"
