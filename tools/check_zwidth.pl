use HTML::Entities;

open(F,"../zzz.txt");
undef $/;
$a=<F>;
close F;
$b = encode_entities($a);

print "\n$a\n$b\n";
