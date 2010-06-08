#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
require Encode;

print header(-charset => 'UTF-8');

my %form;
foreach my $p (param()) {
    $form{$p} = param($p);
}

$file_name = $form{'file_name'};
$file_name =~s/\..{2,3}$/.xml/i;

$form{text_line}=~ s/<[^>]*>//gs; 
$form{text_line} =~s/semicolonxxx/;/g;
$form{text_line} =~s/ampersandxxx/&/g;
$form{text_line} =~s/^\s+//;
#$form{text_line}=~s/<font face='Charis Sil'>//g;
#$form{text_line}=~s/<\/font>//g;
$form{kern}     =~s/^0px//;


open(F,"books/$form{'book'}/xml/$file_name") || die "can't open books/$form{book}/xml/$file_name: #!";
while($line=<F>){

	if($line=~/num="$form{num}"/){
		$line=~s/(>)(.*?)(<\/line>)/$1$form{text_line}$3/;
		$line=~s/(x1=")(.*?)(")/$1$form{x1}$3/;
		$line=~s/(y1=")(.*?)(")/$1$form{y1}$3/;
		$line=~s/(x2=")(.*?)(")/$1$form{x2}$3/;
		$line=~s/(y2=")(.*?)(")/$1$form{y2}$3/;
		$line=~s/(box_height=")(.*?)(")/$1$form{box_height}$3/;
		$line=~s/(font_size=")(.*?)(")/$1$form{font_size}$3/;
		$line=~s/(line_height=")(.*?)(")/$1$form{line_height}$3/;
		$line=~s/(kern=")(.*?)(")/$1$form{kern}$3/;
		$line=~s/(rotation=")(.*?)(")/$1$form{rotation}$3/;
	}

	push(@a,$line);
}	
open(F,">books/$form{book}/xml/$file_name")|| die "can't open $file_name: #!";
print F @a;
close F;

