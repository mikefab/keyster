$book = $ARGV[0];
opendir(DIR,"../books/$book/xml")|| die "../can't open books/$book/xml: $!";
foreach $file(sort readdir DIR){	
  next if $file=~/^\./;
	undef @array;
	open(F,"../books/$book/xml/$file") || die "Can't open $file: $!";
	undef $/;
	$data=<F>;
	close F;
	if ($data=~/row="29"/){
		@data=split(/\n/,$data);	
		%hash=undef;
		foreach $line(@data){
			$row=undef; $col=undef;$text=undef;$num=undef;	
			$row=$2 if $line=~/(row=")(.+?)(")/;
			$text=$2 if $line=~/(">)(.+?)(<\/line>)/;
			$col=$2 if $line=~/(col=")(.+?)(")/;
			$num=$2 if $line=~/(num=")(.+?)(")/;
			$hash{"$row"}{"text"}=$text if $row;
			$hash{"$row"}{"num"}=$num   if $row;;
			$hash{"$row"}{"row"}=$row-1 if $row;;
		}
		for(@data){
			push(@array,"$_\n") unless $_ =~/num="29"/;
		}

		for($i=2;$i<30;$i++){
			$one_less= $i-1;
			$one_more= $i+1;
			foreach $line(@array){
				if($line=~/num="$hash{$i}{"num"}"/){					
					$n=$hash{$i}{"num"}-1;
					$line=~s/row="\d+"/row="$hash{$i}{"row"}"/;
					$line=~s/row="\d+"/row="$hash{$i}{"row"}"/;
					$line=~s/num="$hash{$i}{"num"}"/num="$n"/;

					$line=~s/">.*?<\/line>/">$hash{$one_less}{"text"}<\/line>/;
					print qq($hash{$one_less}{"text"} ..$line);
				}

			}

			$one_less= $i-1;
			$one_more= $i+1;
#			print qq($file $one_less - $hash{$i}{"num"} | $hash{$one_less}{"num"} | $hash{$one_less}{"text"}\n);
		}

		open(F,">../books/$book/xml2/$file") || die "can't open ..books/$book/xml/$file: $!";
		print F @array;
		close F;


	}
}
exit;
__END__
	%hash=$undef;	
	while($line=<F>){


		$hash{"$col"}++ if $col;
		$hash{"$col"}{"$row"}=$text;
#		print "$file $row $col\n" if $row;
	}
	close F;
	foreach $key(keys%hash){
		print "$file .. $key $hash{$key}\n";
		
	}
}
