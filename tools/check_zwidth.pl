#!/usr/bin/perl

#
#$book = $ARGV[0];
#$file= "../books/$book/$book-phonetics.txt";
##open(F, "../books/$book/$book-phonetics.txt") || die "../books/$book/$book-phonetics.txt: $!";
#open IN, ':<encoding(UTF-8)', $file or die $!;
#while($line=<F>){
#  print $line if $line =~ /\x{FEFF}/;
#}
#close

 open (F, "test.txt");
undef $/;
$data=<F>;
close F;

print $data if $data =~ /\x{FEFF}/;

