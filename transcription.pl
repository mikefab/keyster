#!/usr/bin/perl
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use Encode;

print header(-charset => 'UTF-8');
my %form;

@attributes = qw(x1 y1 x2 y2 row col rotation input_box_top box_height mode num font_size line_height kern col row);

foreach my $p (param()) {
    $form{$p} = param($p);
}

if($form{file_name}=~/(.+?)(\..{3}$)/){
  $file_name = "$1.xml";
  unless( -e "books/$form{book}/xml/$file_name" ){
	open(F, ">:encoding(UTF-8)", "xml/$file_name") || die "can't open books/$form{book}/xml/$file_name: $!";
    print F $prefix=qq(<entry>\n  <file>$form{file_name}</file>\n  <height="$form{'image_height'}"/>\n  <width="$form{'image_width'}"/>\n  <view_width="$form{'view_width'}"/>\n  <cols="$form{'cols'}"/>\n  <rows="$form{'rows'}"/>\n  <text_align="$form{'text_align'}"/>\n  <data>\n  </data>\n</entry>);
	close F;
	}

	open(F,"books/$form{book}/xml/$file_name") || die "can't open books/$form{book}/xml/$file_name: $!";
	undef $/;
	$data = <F>;
	@parts = split(/<data>/,$data);
	$prefix=qq($parts[0]<data>\n);
	if($parts[0]=~/(text_align=")(.+?)(")/){
		$text_align=$2;
	}
	$lines = $parts[1];
	@data = split(/<\/data>/,$lines);
	@data = split(/\n/,$data[0]);
}

$highest_line_num = 0;#Get highest line number. Used later for generating divs.
#create hash of line_num keys to lines
for(@data){
	if($_=~/(num=")(.+?)(")/){
		$num=$2;

		if($highest_line_num < $num){ 
			$highest_line_num = $num;
		}
			unless ($form{delete_target} == $num){
			$data_hash{$2}= $_;
		}
	}
}


if($data[0]=~/(rotation=")(.+)(")/){
	$angle = $2;
}

if($data=~/(<cols=")(.+?)(")/)   {$cols=$2;}
if($data=~/(<rows=")(.+?)(")/)   {$rows=$2;}
if($data=~/(<view_width=")(.+?)(")/){$view_width=$2;}
#also need to get last number of first column for setting second point for resetting page area.
for(@data){
	if($_=~/(num=")(.+?)(")/)		{$num=$2;}
	if($_=~/(col=")(.+?)(")/)		{$col=$2;}
	if($_=~/(row=")(.+?)(")/)		{$row=$2;}
	if($_=~/(y1=")(.+?)(")/)		{$y1=$2;}
	$y{$num}=$y1;
	$previous_num = $num-1;	
	if($col==1){
		if(($num>1)&&($num<$rows)){
			$diff = $y{$num} - $y{$previous_num};
			$height_diff{$diff}++;
			@$diff = ($y{$previous_num}, $y{$num})
		}
	}
	
	$col1{$col}=$row; #for getting last row of each column
	$col2{$col}{$row}=$num;#for getting line number of first row of columns for setting second point for resetting page area.

}
$last_row_of_col_1 = $col1{1};
for(sort{$height_diff{$a}<=>$height_diff{$b}} keys%height_diff){
	$common_row_height = $_;
}

$total_lines = $num;
print <<END;

<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> 
END

$counter=1;

print <<END;	

<script type="text/javascript" src="javascript/Zbrowse.js"></script>
<script type="text/javascript" src="javascript/Zprime.js"></script>
<style type="text/css">
.link { cursor: pointer}
</style>

<script>
function go_to_first_available_line(){
	//first check if this is a reload after realignment. If so, then go to that last realigned line
	var temp = parent.parent.frames['editor'].document.getElementById('div_realign_number').innerHTML;
	if(temp.match(/\\d/)){
		parent.parent.frames['editor'].document.getElementById('line_number').value = temp;
		parent.parent.frames['editor'].document.getElementById('button_go_to_line').click();
		return false;
	}

	for(i=1; i<=199; i++){
		if (document.getElementById(i).style.display=="inline"){
			parent.parent.frames['editor'].document.getElementById('line_number').value = i;
			parent.parent.frames['editor'].document.getElementById('button_go_to_line').click();
			break;
		}
//Must be a an empty page?
			parent.parent.frames['editor'].document.getElementById('line_number').value = 1;
			parent.parent.frames['editor'].document.getElementById('button_go_to_line').click();
	}
}

//Sets points in fix_xml area for aligning first column. For rotation
function load_alignment_points(){
	parent.parent.frames['editor'].document.getElementById('view_width').value = "$view_width";
  parent.parent.frames['editor'].document.getElementById('Mouse1X').value = Math.round(document.getElementById(1).getAttribute('x1'));
  parent.parent.frames['editor'].document.getElementById('Mouse1Y').value = Math.round(document.getElementById(1).getAttribute('y1'));
  parent.parent.frames['editor'].document.getElementById('Mouse2X').value = Math.round(document.getElementById($last_row_of_col_1).getAttribute('x1'));
  parent.parent.frames['editor'].document.getElementById('Mouse2Y').value = Math.round(document.getElementById($last_row_of_col_1).getAttribute('y1'));
END
if($form{file_name}){
  for($i=2;$i<=$cols;$i++){

    print qq(  parent.parent.frames['editor'].document.getElementById("x_$i").value = Math.round(document.getElementById("$col2{$i}{1}").getAttribute('x1'));\n); 	
    print qq(  parent.parent.frames['editor'].document.getElementById("y_$i").value = Math.round(document.getElementById("$col2{$i}{1}").getAttribute('y1'));\n); 	

  }
	$previous = $i -1;

    print qq(  parent.parent.frames['editor'].document.getElementById("x_$i").value = document.getElementById("$col2{$previous}{1}").getAttribute('x2');\n); 	
    print qq(  parent.parent.frames['editor'].document.getElementById("y_$i").value = document.getElementById("$col2{$previous}{1}").getAttribute('y1');\n); 	
    print qq(  parent.parent.frames['editor'].document.getElementById("x_$i").style.display="inline";); 
    print qq(  parent.parent.frames['editor'].document.getElementById("y_$i").style.display="inline";); 	
    print qq(  parent.parent.frames['editor'].document.getElementById("btn_x_$i").style.display="inline";); 	

$i+=1; #this should be one higher than the number of columns. 
  for($i=$i;$i<=19;$i++){

  print qq(  parent.parent.frames['editor'].document.getElementById("common_row_height").innerHTML=$common_row_height;\n);
  print qq(  parent.parent.frames['editor'].document.getElementById("row_top").value="@$common_row_height[0]";\n);
  print qq(  parent.parent.frames['editor'].document.getElementById("row_bottom").value="@$common_row_height[1]";\n);
 
   print qq(  parent.parent.frames['editor'].document.getElementById("x_$i").value="";\n);
  print qq(  parent.parent.frames['editor'].document.getElementById("x_$i").style.display="none";\n);  	
  print qq(  parent.parent.frames['editor'].document.getElementById("y_$i").value="";\n);
  print qq(  parent.parent.frames['editor'].document.getElementById("y_$i").style.display="none";\n);  	
  print qq(  parent.parent.frames['editor'].document.getElementById("btn_x_$i").style.display="none";\n);  	
  }
}
print qq(});	

print <<END;


function set_general_params(){
  document.getElementById('text_align').value="$text_align";
  parent.parent.frames['editor'].document.getElementById('realign_x').value="";
  parent.parent.frames['editor'].document.getElementById('realign_y').value="";
  parent.parent.frames['editor'].document.getElementById('realign_row').value="";
  parent.parent.frames['editor'].document.getElementById('new_font_size').value   = document.getElementById(1).getAttribute('font_size').replace(/px/,"");
  parent.parent.frames['editor'].document.getElementById('new_line_height').value = document.getElementById(1).getAttribute('line_height').replace(/px/,"");
  if(document.getElementById(1).getAttribute('kern')){
    parent.parent.frames['editor'].document.getElementById('new_kern').value 	  = document.getElementById(1).getAttribute('kern').replace(/px/,"");
  }
}

</script>
</head>

END

if($form{file_name}){
  print qq(<body onLoad="set_general_params();load_alignment_points();go_to_first_available_line();" >);
}else{
	print qq(<body>);
}

print <<END;
  <button id="sniper" name="sniper" style="display:none;"; href="" onClick="window.location.href=this.getAttribute('href');">Scroll to current line</button> 
  <div id="list_of_lines" name="list_of_lines"></div>
  <div id="angle" name="angle"></div>
  <table><tr><td>Total lines:</td><td><div id = "total_lines">$total_lines</div></td></tr></table><br>


END
#get highest line number in file
for($counter=1;$counter<=$highest_line_num;$counter++){
  if($data_hash{$counter}){ #if text exists for this key
  %hash=undef;
#  if($data_hash{$counter} =~/(text=")(.+?)(")/){ #get text
  $text_line=undef;
  if($data_hash{$counter} =~/(>)(.+?)(<\/line>)/){ #get text
	$text_line=$2;
  }
  if($data_hash{$counter}=~/(num=")(.+?)(")/){ #get line number
	$num=$2;
  }
  for(@attributes){
	if($data_hash{$counter}=~/($_\s*=\s*")(.*?)(")/){ $hash{$_} = $2; push(@$_,$2);}
  }

  print qq(<div id="$num" class="link" onClick="parent.parent.frames['editor'].unpaint_divs();
										this.style.backgroundColor='yellow';
										parent.parent.frames['editor'].document.getElementById('line_number').value='$num';
										parent.parent.frames['editor'].document.getElementById('button_go_to_line').click();" style="display:inline;" );
	

	for(keys%hash){
		print qq($_="$hash{$_} ");
	}
			
#	print qq(>$num. $text_line</div><br>);
	print qq(>$num. <font face='Charis Sil'>$text_line</font></div><br>);


	}else{

	print qq(<div id="$counter" class="link"  onClick="parent.parent.frames['editor'].document.getElementById('line_number').value='$counter'; parent.parent.frames['editor'].document.getElementById('button_go_to_line').click();" style="display:none;" );	

			
#	print qq(><br></div>);
	print qq(></div><br>);

	}
}

for($i=$num;$i<200;$i++){
	print qq(<div id="$i" class="link" onClick="parent.parent.frames['editor'].document.getElementById('line_number').value='$i'; parent.parent.frames['editor'].document.getElementById('button_go_to_line').focus();parent.parent.frames['editor'].document.getElementById('button_go_to_line').click();" style="display:none;"></div>);	
	
}
print <<END;


		<form action = "transcription.pl" method = "post" id = "form_transcription" name = "form_transcription" >
			<input type = hidden id = "image_width" name = "image_width" />
			<input type = hidden id = "image_height" name = "image_height" />
			<input type = hidden id = "file_name" name = "file_name" />
			<input type = hidden id = "book" name = "book" />
			<input type = hidden id = "text_align" name = "text_align" />
			<input type = hidden id = "cols" name = "cols" />
			<input type = hidden id = "rows" name = "rows" />					

		</form>


<script>
//	for(i=0;i<lines.length;i++){
//	counter= i+1;
//	document.write("<span class='link' onClick=\\"parent.parent.frames['editor'].document.getElementById('line_number').value='" + counter +"'; parent.parent.frames['editor'].document.getElementById('button_go_to_line').click();\\">"+counter+"."+lines[i].line+"<\/span><br>" );

//}
</script>


	</body>
</html>
END

