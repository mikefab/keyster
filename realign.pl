#!/usr/bin/perl
#Receives book, file name, (page name), and amount to increase y
#Resets y position for lines with lines higher than received y.
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);

print header;

my %form;

foreach my $p (param()) {
    $form{$p} = param($p);
}
$form{file_name}=~s/\..{2,3}/.xml/;
open(F,"books/$form{book}/xml/$form{file_name}")||die "can't open books/$form{book}/$form{file_name}: $!";
undef $/;
$data=<F>;
close F;
@data=split(/\n/,$data);
foreach $line(@data){
	$line.="\n";
  if($line=~/(y1=")(.+?)(")/)	{
    $y1_loop=$2;
	  $y1_mod = $y1_loop + $form{amount_to_increase_y};
    if($y1_loop>=$form{old_y1}){
      $line=~s/y1="$y1_loop"/y1="$y1_mod"/;
	  }
  }
}
open(F,">books/$form{book}/xml/$form{file_name}")||die "can't open books/$form{book}/$form{file_name}: $!";
print F @data;
close F;
