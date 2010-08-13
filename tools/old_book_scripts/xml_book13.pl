#!/usr/bin/perl
#SPECIFIC TO $book

use Encode;


$view_width="865";
$x = 1357;
$y = 985;
$h = 116;
$w = 865;
$book="book13";
mkdir "../books/$book/xml";
opendir(DIR,"../books/$book/pre_xml")|| die "can't open books/$book/pre_xml: $!";

foreach $file(readdir DIR){
  next if $file=~/^\./;
  %hash=undef;	
  $cols=undef;
  @a=undef;
  $image_file=$file;
  $image_file=~s/.txt/.png/;
  print "$file\n";
  open(F,"../books/$book/pre_xml/$file")|| print "can't open: $!";
  @data=<F>;
  close F;

  for(@data){#get the common number of columns
  	@line=split(/\t/,$_);

	$hash{$#line}++;
  }
  for(sort {$hash{$a}<=>$hash{$b}} keys%hash){ #get the common number of columns	

	$cols=$_;
  }	

  $cols++;

  $rows=$#data+1;
  $intro=qq(<entry>\n  <file>$image_file</file>\n  <width="3050"/>\n  <height="4500"/>\n  <view_width="$view_width"/>\n  <cols="$cols"/>\n  <rows="$rows"/>\n  <text_align="left"/>\n  <data>);
  $rows = $#data;	

	($trash,$zero,$number,$trash) = $file=~/(^.+?)(0)(\d+)(\.txt)/;


	
  $line_counter_all=1;	 

  for($i=0;$i<$cols;$i++){
	$row_counter=1;	
		for(@data){
		  $_=~s/\n//;
		  @line=split(/\t/,$_);
		  $x1  = ($x + ($i*$w)-($row_counter*$variance));
		  $y1 = ($y + (($row_counter-1)*$h));
		  $y2 = $y1+h; 
		  $x2  = $x1+$view_width;
		  $col=$i+1;
		  next if $line[$i]=~//;
		  $xml_line = qq(    <line num="$line_counter_all" col="$col" row="$row_counter" x1="$x1" x2="$x2" y1="$y1" y2="$y2" box_height="150" font_size="65px" line_height="140px" kern="" rotation="$angle">$line[$i]</line>\n);
		  push(@a,$xml_line);
		  $row_counter++;
		  $line_counter_all++;
		}
	}

  print "opening $file.xml\n";
  $file=~s/.txt/.xml/;
  open(F,">../books/$book/xml/$file")|| die "can't open $file_name.xml: $!";
  print F "$intro\n";
  print F @a;
  print F qq(  </data>\n</entry>);
  close F;	
}

