#!/usr/bin/perl
#SPECIFIC TO $book

use Encode;


$view_width="825";
$x = 363;
$y = 510;
$h = 133;
$w = 1277;
$book="book8";
opendir(DIR,"books/$book/pre_xml")|| die "can't open books/$book/pre_xml: $!";

foreach $file(readdir DIR){
  next if $file=~/^\./;
  %hash=undef;	
  $cols=undef;
  @a=undef;
  $image_file=$file;
  $image_file=~s/.txt/.png/;

  open(F,"books/$book/pre_xml/$file")|| print "can't open: $!";
  @data=<F>;
  close F;
  $total=$#data+1;
  $mid= $total/2;
  print "$file $total $mid\n";


$cols=2;

  $rows=$mid;
  $intro=qq(<entry>\n  <file>$image_file</file>\n  <width="3050"/>\n  <height="4500"/>\n  <view_width="$view_width"/>\n  <cols="$cols"/>\n  <rows="$rows"/>\n  <text_align="left"/>\n  <data>);
  $rows = $#data;	

	($trash,$zero,$number,$trash) = $file=~/(^.+?)(0)(\d+)(\.txt)/;


	
  $line_counter_all=1;	 



	$c=1;
	$r=1;
	for(@data){
	  $r=1 if $r==($mid+1);
	  $col=1 if $c<=$mid;
	  $col=2 if $c>$mid;
	  $row_counter=$r;

	  $_=~s/\n//;
	  $x1  = ($x + (($col-1)*$w)-($row_counter*$variance));
	  $y1 = ($y + (($row_counter-1)*$h));
	  $y2 = $y1+h; 
	  $x2  = $x1+$view_width;


		  $xml_line = qq(    <line num="$line_counter_all" col="$col" row="$row_counter" x1="$x1" x2="$x2" y1="$y1" y2="$y2" box_height="150" font_size="65px" line_height="140px" kern="">$_</line>\n);
		  push(@a,$xml_line);
		  $row_counter++;
		  $line_counter_all++;
		  $c++;
		  $r++;
		}


#  print "opening $file.xml\n";
  $file=~s/.txt/.xml/;
  open(F,">books/$book/xml/$file")|| die "can't open $file_name.xml: $!";
  print F "$intro\n";
  print F @a;
  print F qq(  </data>\n</entry>);
  close F;	
}


