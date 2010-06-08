#!/usr/bin/perl
#SPECIFIC TO $book

use Encode;
$book = $ARGV[0];
opendir(DIR,"../books/$book/pre_xml")|| die "can't open books/$book/pre_xml: $!";

foreach $file(sort(readdir DIR)){
  next if $file=~/^\./;
  %hash=undef;	
  $cols=undef;
  @a=undef;

  open(F,"../books/$book/pre_xml/$file")|| print "can't open: $!";
  @data=<F>;
  close F;

  pop(@data) if (length($data[$#data])<4); #for book2. 
  for(@data){#get the common number of columns
  	@line=split(/\t/,$_);
	  $hash{$#line}++;
  }
  for(sort {$hash{$a}<=>$hash{$b}} keys%hash){ #get the common number of columns	
	$cols=$_;
  }	
  $cols++;
  $rows = $#data;	
	($trash,$zero,$number,$trash) = $file=~/(^.+?)(0)(\d+)(\.txt)/;
  $line_counter_all=1;	 
  for($i=0;$i<$cols;$i++){
	$row_counter=1;	
		for(@data){
		  $_=~s/\n//;
		  @line=split(/\t/,$_);
		  $pre_length=undef;
		  $post_length=undef;	
		  $col=$i+1;
		  next if $line[$i]=~//;
      $line[$i]=~s/\s+/ /g;
      $line[$i]=~s/^\s+//;
      $line[$i]=~s/\s+$//;
		  $pre_length=length($line[$i]);	
		  $file=~s/.txt/.xml/;
		  open(F,"../books/$book/xml/$file") ||die "can't open $file: $!";
		  while($line=<F>){
			if($line=~/num="$line_counter_all"/){
				$text=$2 if $line=~/(>)(.+?)(<)/;
				$text=~s/\s+/ /g;
				$text=~s/^\s+//;
			  $text=~s/\s+$//;
				$post_length= length($text);

			}
		  }
		  $diff = $pre_length-$post_length;
	  if($pre_length>$post_length){
#	   if($diff>2){	
		  	print "..$file $line_counter_all $pre_length $post_length diff: $diff $line[$i] **** $text \n";
		 }
		  close F;
			  $row_counter++;
		  $line_counter_all++;
		}
	}
}
