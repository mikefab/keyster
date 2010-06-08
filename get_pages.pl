#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use Image::Size;
require Encode;

print header(-charset => 'UTF-8');

my %form;
foreach my $p (param()) {
    $form{$p} = param($p);
}



$options=qq(Page: <select id = "select_scripture" onChange = "do_image_change_stuff();" style = "display:inline;"><option>Please choose an image</option>);
opendir(DIR,"books/$form{book}/images");
for(sort { $a cmp $b }(readdir(DIR))){
	next if /^\./;
	($globe_x, $globe_y) = imgsize("books/$form{book}/images/$_");
	if($_!~/\.db$/i){
		
		$options.=qq(<option x_value="$globe_x" y_value="$globe_y" >$_</option>\n);}
}
$options.=qq(</select><button id = "btn_next_page" name="btn_next_page" onClick="next_page();" style="display:inline;">Next page</button>);

open(F,"escapes2.txt") || die "can't open escapes2.txt: $!";
foreach $line(<F>){
	chomp;
	$line=~s/\n//;
	#$line=~s/\\/\\\\/g;

	@line=split(/\t/,$line);
	
	  utf8::encode($line[1]);
	  utf8::decode($line[1]);
	  utf8::encode($line[0]);
	  utf8::decode($line[0]);

  	$reverse_escape{"$line[1]"}=qq($line[0]);	
#	$escape{$line[0]}=qq($line[1]);	
}
close F;





open(F,"books/$form{book}/characters.txt");#make sure that the first line of this file is blank.
while(<F>){
  $_=~s/\n//;
  $character = $_;
  if($character!~/\W/){
    $string.= qq(&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;);
	next;

  }
	$character=~s/\s//g;
	$string.=qq(<input class="button" type="button" id="some_button" name="some_button" onClick = "check_character('$character');" title="$reverse_escape{$_}" value="$_">);
}
close F;
$options.=qq(***$string);
print $options;
