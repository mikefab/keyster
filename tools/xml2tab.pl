#!/usr/bin/perl
$c=1;
$book = $ARGV[0];
open(F,">../books/$book/$book-phonetics.txt") || die "../books/$book/lines.txt: $!";close F;

opendir(DIR,"../books/$book/xml")|| die "../can't open books/$book/xml: $!";
for(sort readdir DIR){	
	next if $_=~/^\./;	
	%hash=undef;
	open(F,"../books/$book/xml/$_");
	undef $/;
	$data=<F>;
	$data=~s/&nbsp;/ /g;
	close F;

	foreach $line(split(/\n/,$data)){
		$col=undef; $row=undef; $text=undef;
		if($line=~/(row=")(.+?)(")/){
			$row=$2;
		}

		if($line=~/(>)(.*?)(<\/line>)/){
			$text=$2;

		}
		if($row){
			$hash{$row}.=qq($text\t);
		}
	}

	open(F,">>../books/$book/$book-phonetics.txt") || die "can't open new_xml/$_.txt: $!";
	$_=~s/\.xml$//;
	print F qq($_ ________\n);
	foreach $key(sort{$a<=>$b} keys%hash){
		$hash{$key}=~s/\t$//;
		if($key){
		print F "$hash{$key}\n";
		$counter1++ if length($hash{$key})<1;
		print "...$_ -$hash{$key}- $key\n" if length($hash{$key})<10;
		}
	}

	close F;

$c++;
}print "$counter1\n";
