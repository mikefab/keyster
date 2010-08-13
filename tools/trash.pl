 open my $FH, ">:raw:encoding(UTF16-LE):crlf:utf8", "test.txt";
   print $FH "-\x{FEFF}-";
   print $FH "hello unicode world!\nThis is a test.\n";
   close $FH;
