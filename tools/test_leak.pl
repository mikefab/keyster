open(F,"../books/book14/book14-phonetics_o.txt") || die "can't open: $!";
@a=<F>;
close F;


open(F,"../books/book14/book14-phonetics.txt") || die "can't open: $!";
@b=<F>;
close F;

print "$#a $#b\n";

open(F,">trash.txt");
close F;

for($i=0;$i<=$#a;$i++){

	print  "$a[$i]$b[$i]" if length($a[$i]) != length($b[$i]);

} 




