$book = $ARGV[0];
opendir(DIR,"../books/$book/xml")|| die "../can't open books/$book/xml: $!";
for(sort readdir DIR){	
  next if $_=~/^\./;
  $data=undef;
  open(F,"../books/$book/xml/$_")||die "can't open xml/$_";
	undef $/;
  $data=<F>;
print "$_ tag\n" if $data=~/apple/i;
  close F;
	if ($data=~/<font class='Apple-style-span' face=''Charis Sil''>/){
    open(F,">../books/$book/xml/$_")||die "can't open xml/$_";
    $data=~s/<font class='Apple-style-span' face=''Charis Sil''>//g;
	  print F $data;
	  close F;
	  print "$_\n";
	}
}
