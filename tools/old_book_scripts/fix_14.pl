$book = $ARGV[0];
opendir(DIR,"../books/$book/xml2")|| die "../can't open books/$book/xml: $!";
foreach $file(sort readdir DIR){	
  next if $file=~/^\./;
	open(F,"../books/$book/xml2/$file");
	while(my $line=<F>){
		undef $text;
		undef $num;
		$text=$2 if $line=~/(">)(.*?)(<\/line>)/;
		$num=$2 if $line=~/(num=")(\d+)(")/;

		reset_value($file,$num,$text) if $num;
	}
	close F;
}

sub reset_value(){
	undef @a;
	open(FILE,"../books/$book/xml/$_[0]");
	while($xian=<FILE>){
		if ($xian=~/num="$_[1]"/){
			$t=$2 if $xian=~/(">)(.*?)(<\/line>)/;
			$xian=~s/(">)(.*?)(<\/line>)/$1$_[2]$3/;
			print "$_[1] $t $_[2] $xian\n";
		}
		push(@a,$xian);	

	}
	close FILE;
	open(FILE,">../books/$book/xml/$_[0]") || die "Can't open xml3/$_[0]: $!";
	print FILE @a;
	close FILE;
}
