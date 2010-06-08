#!/usr/bin/perl

opendir(DIR,"../books/book1/pre_xml");
@files = readdir(DIR);
splice(@files,0,2);

foreach $file_name(@files){
  $file_name=~s/\..{2,3}/.txt/;
  open(F,"../books/book1/pre_xml/$file_name")|| die "can't open: $!";
  undef $/;
  $data=<F>;
  close F;

  $file_name=~s/\..{2,3}/.xml/;
  open(F,"../books/book1/xml2/$file_name")|| die "can't open $file_name.xml: $!";
  undef $/;
  $data_xml=<F>;
  close F;


  @data=split(/\n/,$data);
  for(@data){#get the common number of columns
  	@line=split(/\t/,$_);
	$hash{$#line}++;
  }
  for(sort {$hash{$a}<=>$hash{$b}} keys%hash){ #get the common number of columns
	$cols=$_;
  }	
  $rows = $#data+1;
  $total_cols = $cols+1;
  $r_c  = qq(  <cols="$total_cols"/>\n  <rows="$rows"/>\n);
  $data_xml=~s/(<width="4020"\/>\n)/$1$r_c/;

  $line_counter_all=1;
  for($i=0;$i<=$cols;$i++){
    $row_counter=1;
	for(@data){
	  @line = split(/\t/,$_);
	  $col=$i+1;
	  $xml_line =  qq( col="$col" row="$row_counter");
	  $data_xml=~s/(num="$line_counter_all")/$1$xml_line/ ;
	  $row_counter++;
	  $line_counter_all++;
	}
  }
  open(F,">../books/book1/xml/$file_name")|| die "can't open $file_name.xml: $!";
  print F $data_xml;
  close F;
}


