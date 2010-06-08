#!/usr/local/bin/perl
$book = $ARGV[0];

print "diffs:\n";
system("perl semi_diff.pl $book");


print "Repeat Rows###########:\n";
system("perl check_repeat_rows.pl $book");

print "Repeat xy##########:\n";
system("perl check_repeat_xy.pl $book");

print "non ascending y###########:\n";
system("perl check_ascending_y.pl $book");

print "font tags##########:\n";
system("perl check_unwanted_tag.pl $book");

print "asterix:\n";
system("perl check_asterix.pl $book");



