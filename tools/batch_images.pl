#!C:\bin\Perl\bin\perl.EXE
use Image::Pbm();
use Image::Size;
$book = $ARGV[0];
mkdir "../books/$book/images_expanded";
opendir(DIR,"../books/$book/images")||die "can't open ../books/$book/images :$!";


foreach $image_name(readdir DIR){
	next if $image_name=~/(^\.|thumbs.db)/i;
#$image_name = $files[4];
  
  	($globe_x, $globe_y) = imgsize("../books/$book/images/$image_name");

  if ($image_name =~ /.png/){
	 $image_name =~s/\..{3}$//;	
	  $call = system("pngtopnm ../books/$book/images/$image_name.png> ../books/$book/images_expanded/test.pbm");
  }

#  if ($form{"image_name"} =~ /.png/){
#	  $form{"image_name"} =~s/\..{3}$//;	
#	  $call = system("pngtopnm ../books/$book/images/$image_name.png> ../books/$book/images_expanded/test.pbm");
## }
print "width: $image_name $globe_x\n";
  my $i = Image::Pbm->new(-width => $globe_x, -height => 300 );
  # $i->line     ( 2, 2, 22, 22 => 1 );
  # $i->rectangle( 4, 4, 40, 20 => 1 );
  # $i->ellipse  ( 6, 6, 30, 15 => 1 );
  # $i->xybit    (       42, 22 => 1 );
  #print $i->as_string;
  $i->save("../books/$book/images_expanded/buffer.pbm");
  
  $call = system("pnmcat -topbottom ../books/$book/images_expanded/buffer.pbm ../books/$book/images_expanded/test.pbm >../books/$book/images_expanded/end.pbm") ;
  $call = system("pnmcat -topbottom ../books/$book/images_expanded/end.pbm  ../books/$book/images_expanded/buffer.pbm >../books/$book/images_expanded/end2.pbm") ;

  $call = system("pnmtopng ../books/$book/images_expanded/end2.pbm > ../books/$book/images_expanded/$image_name.png");
  print "You may now work with $image_name\n";
  unlink("../books/$book/images_expanded/test.bpm");
 }
