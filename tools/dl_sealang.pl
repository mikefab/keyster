use WWW::Mechanize;
my $mech = WWW::Mechanize->new();

$book=$ARGV[0];


opendir (DIR,"../books/$book/images");
for (sort readdir(DIR)){
  next if $_=~/(^\.|thumbs)/i;

	$_=~s/.png$/.xml/;
	$url=" http://sealang.net/project/keyster/books/$book/xml/$_";	
	print "Getting $url\n";
	$mech->get( $url );
  $page = $mech->content();
	open(F,">../books/$book/xml/$_");
  binmode F, ":utf8";
	print F $page;
	close F;
}



