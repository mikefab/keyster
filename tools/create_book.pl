#!/usr/bin/perl
#SPECIFIC TO $book
#creates xml files based on pre xml files.
#set x and y for the first line.
#set the hight and width of general lines.
use Encode;


$book=$ARGV[0];

open(F,"book_index.txt");
while($line=<F>){
$line=~s/\n//;
@line=split(/\t/,$line);
	($x,$y,$h,$w,$view_width,$cols)=($line[1],$line[2],$line[3],$line[4],$line[5],$line[6]) if $line[0]eq "$book";

}
close F;

$table_or_number=$cols;

mkdir "../books/$book/xml" || print "Can't: $!";

opendir(DIR,"../books/$book/pre_xml")|| die "can't open books/$book/pre_xml: $!";

foreach $file(readdir DIR){
  next if $file=~/^\./;

if($table_or_number=~/\d/){
  %hash=undef;	
  @a=undef;
  $image_file=$file;
  $image_file=~s/.txt/.png/;

  open(F,"../books/$book/pre_xml/$file")|| print "can't open: $!";
	undef $/;
	$data=<F>;
	$data=~s/\f//g;
	$data=~s/\r//g;
  @data=split(/\n/,$data);
  close F;
  $total=$#data+1;
  $mid= $total/$cols;
  print "$file $total $mid\n";
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

		$_=~s/\n//;
		$_=~s/\r//;
		  $xml_line = qq(    <line num="$line_counter_all" col="$col" row="$row_counter" x1="$x1" x2="$x2" y1="$y1" y2="$y2" box_height="150" font_size="65px" line_height="140px" kern="">$_</line>\n);
		  push(@a,$xml_line);
		  $row_counter++;
		  $line_counter_all++;
		  $c++;
		  $r++;
		}

}else{
  %hash=undef;	
  @a=undef;$cols=undef;
  $image_file=$file;
  $image_file=~s/.txt/.png/;
  open(F,"../books/$book/pre_xml/$file")|| print "can't open: $!";
	undef $/;
	$data=<F>;
	$data=~s/\f//g;
	$data=~s/\r//g;
  @data=split(/\n/,$data);
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

}

  $file=~s/.txt/.xml/;
  open(F,">../books/$book/xml/$file")|| die "can't open $file_name.xml: $!";
  print F "$intro\n";
  print F @a;
  print F qq(  </data>\n</entry>);
  close F;	
}


