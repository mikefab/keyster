#!/usr/bin/perl
use Encode;
use Math::Trig;
use Math::Complex;
use Math::Round;

$image_width=4020;
$image_height=5950;
$x = 840;
$y = 835;
$h = 136;
$w = 1015;
$second_x = 815;
$second_x = 815;

opendir(DIR,"../books/book1/pre_xml");
@files = readdir(DIR);
splice(@files,0,2);

foreach $file_name(@files){
  %hash=undef;
  @a=undef;
  $file_name=~s/\..{2,3}/.txt/;
  open(F,"../books/book1/pre_xml/$file_name")|| die "can't open: $!";
  undef $/;
  $data=<F>;
  close F;
  @data=split(/\n/,$data);
  for(@data){#get the common number of columns
  	@line=split(/\t/,$_);
	$hash{$#line}++;
  }
  for(sort {$hash{$a}<=>$hash{$b}} keys%hash){ #get the common number of columns
	$cols=$_;
  }	
  $rows = $#data;
  $variance = ($x-$second_x)/($#data-1); #the page might be slanted

  $file_name=~s/\..{2,3}$//;
  $prefix=qq(<entry>\n  <file>$file_name.gif</file>\n  <height="$image_height"/>\n  <width="$image_width"/>\n  <cols="$cols"/>\n  <rows="$#data"/>\n  <view_width="1015"/>\n   <text_align="left"/>\n  <data>\n);
  $line_counter_all=1;
  for($i=0;$i<=$cols;$i++){
    $row_counter=1;
	for(@data){
	  $x_len = length($_);
	  if($x_len<1){print "$line_counter_all \n";}
	  @line = split(/\t/,$_);
	  $col=$i+1;
	  $xml_line =  qq(    <line num="$line_counter_all" row="$row_counter" col="$col" );
	  $x1 		   = round(($x + ($i*$w)-($row_counter*$variance)));
	  $xml_line .= qq(x1="$x1" );
	  $y1 	   = round(($y + (($row_counter-1)*$h)));
	  $xml_line .= qq(y1="$y1" ) ;
	  $x2 = $x1+1000;
	  $xml_line .= qq(x2="$x2" );	
	  $xml_line .= qq(y2="$y1" );
	  $xml_line .= qq(box_height=").$h . qq(px");
	  $form{'new_font_size'} =~s/\s//g;
	  $form{'new_line_height'} =~s/\s//g;
	  $form{'new_kern'} =~s/\s//g;
$line[$i]=~s/\n//g;
	  $xml_line .= qq( font_size="68px" line_height="76px">$line[$i]</line>);
		$xml_line=~s/\n//g;
		$xml_line=qq($xml_line\n);		
	  push(@a,$xml_line);
	  $row_counter++;
	  $line_counter_all++;
	}
  }
  print "opening $file_name.xml\n";
  open(F,">../books/book1/xml/$file_name.xml");
  print F $prefix;
  print F @a;
  print F qq(  </data>\n</entry>\n);
  close F;	
}


