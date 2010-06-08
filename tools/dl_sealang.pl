use WWW::Mechanize;
my $mech = WWW::Mechanize->new();

$book=$ARGV[0];

$hash{"book8"}{start}=221;
$hash{"book8"}{end}=280;

$hash{"book9"}{start}=248;
$hash{"book9"}{end}=293;



for($i=$hash{$book}{start};$i<=$hash{$book}{end};$i++){
	$name="b0$i.xml";
	
	$url=" http://sealang.net/project/keyster/books/$book/xml/$name";	
	print "Getting $url\n";
	$mech->get( $url );
  $page = $mech->content();
	open(F,">../books/$book/xml/$name");
  binmode F, ":utf8";
	print F $page;
	close F;
}

