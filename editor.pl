#!/usr/bin/perl
use Encode;
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use Image::Size;
use utf8;
print header(-charset => 'UTF-8');

open(F,"escapes2.txt"); #This file contains escape characters combinations and their symbols
foreach $line(<F>){
	chomp;
	$line=~s/\n//;
	#$line=~s/\\/\\\\/g;

	@line=split(/\t/,$line);
	  $line[0]=~s/\s//;
	  $line[1]=~s/\s//;
	  utf8::encode($line[1]);
	  utf8::decode($line[1]);
	  utf8::encode($line[0]);
	  utf8::decode($line[0]);
  	$escape{"\\\\\\\\$line[0]"}=qq($line[1]);	
  	$reverse_escape{"$line[1]"}=qq($line[0]);	
#	$escape{$line[0]}=qq($line[1]);	
}
close F;



open(F,"diacritics.txt");
foreach $line(<F>){
	chomp;
	$line=~s/\n//;
  $line=~s/\s//g;
	#$line=~s/\\/\\\\/g;
 	$diacritic{"$line"}=qq(1);	
}
close F;

opendir(DIR,"images");
@scriptures = readdir(DIR);
splice(@scriptures,0,2);	
@scriptures=sort(@scriptures);

@attributes= qw(file_name book x1 y1 x2 y2 image_width_px image_height_px line_height font_size kern rotation box_height num col row text_align);

$height_expansion_increment = 600; #this is the amount of the white padding added on top and bottom of image


open(F,"characters.txt");#This is a list of characters a user can inject into the text space. Array will be used to create button panel
 while(<F>){
   push(@characters,$_);
 }
 close F;


print <<END;
<!DOCTYPE html>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> 
       <link type="text/css" href="javascript/themes/base/ui.all.css" rel="stylesheet" />
        <script type="text/javascript" src="javascript/jquery-1.3.2.js"></script>
        <script type="text/javascript" src="javascript/ui/ui.core.js"></script>
        <script type="text/javascript" src="javascript/ui/ui.slider.js"></script>
		    <script type="text/javascript" src="javascript/Zbrowse.js"></script>
		    <script type="text/javascript" src="javascript/Zprime.js"></script>
		    <script type="text/javascript" src="javascript/browser_detect.js"></script>


<STYLE TYPE="text/css"> 
DIV.button {
	font-size:18px;
	font-family:Charis Sil;
	}
 
input.button {
	
	font-size: inherit;
	font-family: inherit;
	}
</STYLE> 


  <script type="text/javascript">


  
function stateChanged()  {  
  if (xmlHttp.readyState==4 || xmlHttp.readyState=="complete")  {  
	  var thing = xmlHttp.responseText;
	  var mySplitResult = thing.split("***");
    document.getElementById('button_div').innerHTML = mySplitResult[1];
    document.getElementById("div_pages").innerHTML  = mySplitResult[0];  
   }  
   else {  
   }  
}  


function GetXmlHttpObject(handler)  {  
  var objXMLHttp=null  
  if (window.XMLHttpRequest)  {  
    objXMLHttp=new XMLHttpRequest()  
	}  
   else if (window.ActiveXObject)  {  
     objXMLHttp=new ActiveXObject("Microsoft.XMLHTTP")  
   }  
   return objXMLHttp  
}  

function htmlData(url, qStr)  {  
  if (url.length==0)  {  
    document.getElementById("div_pages").innerHTML="";  
    return;  
  }  
  xmlHttp=GetXmlHttpObject()  
  if (xmlHttp==null)  {  
    alert ("Browser does not support HTTP Request");  
    return;  
  }  
  
   url=url+"?"+qStr;  
   url=url+"&sid="+Math.random();  
   xmlHttp.onreadystatechange=stateChanged;  
   xmlHttp.open("GET",url,true) ;  
   xmlHttp.send(null);  
} 


function get_start_selection(){ //Returns left or right depending on where the user began selection in text space
 	if (window.getSelection) {
    var selObj = window.getSelection();
		if(selObj.anchorNode==selObj.focusNode){ //Section covers singler node
	  	if(selObj.anchorOffset < selObj.focusOffset){ //user highlighted left to right.(only within a single node)
				return("left");
			}else{
				return("right");
			}
		}else{ //Selection covers multiple nodes
			var anchor_pos = selObj.focusNode.compareDocumentPosition( selObj.anchorNode ); 
			var focus_pos = selObj.anchorNode.compareDocumentPosition( selObj.focusNode ); 
			if(anchor_pos<focus_pos){
				return("left");
			}else{
				return("right");
			}
		}
	}
}




function check_character(character) { //Used on keyup and when a character button is pushed. Checks for escape characters, makes substitutions over single and multi nodes

	var sel_start = get_start_selection(); //Returns left or right depending on which direction user made selection

 	if (window.getSelection) {
		var selObj = window.getSelection();
    if ((selObj.anchorNode == null) && (!character)){ // This is just a user pressing page up or page down. Exit
  	  return false;
    }
    if ((selObj.anchorNode == null) && (character)){ //I'm not able to trigger this. Had before: User has clicked a button in Characters panel. Insert character and then look behind it for possible escape.
			alert('find me and explain me');
	    selObj.anchorNode.nodeValue = character;
	  }

	  if(document.getElementById('text_space').innerHTML.length==0){ //LINE IS EMPTY, just insert character
 		  document.getElementById('text_space').innerHTML=character;
		  selObj.nodeValue=character;
		  return_cursor(selObj.focusNode, 2); //FIREFOX DOESN't HANDLE THIS. Need alternative method to place cursor
		  return false;
	  }

 		if(selObj.anchorOffset < selObj.focusOffset){ //user highlighted left to right.(only within a single node)
			cursorPos = selObj.anchorOffset;
		}else{ //user highlighted right to left
			cursorPos = selObj.focusOffset;
		}

	  //Check previous character to determine if it's an Escape character indicating need for substitution
	  if(cursorPos>0){ //If cursorPos is not 0, then selection does not begin or end at the start of a node.
	    var pre  = selObj.anchorNode.nodeValue.substring(0,cursorPos);
		  var post = selObj.anchorNode.nodeValue.substring(cursorPos,selObj.anchorNode.nodeValue.length);

      for (var i in my_escapes) {
			  var escape_array = i.split("");

			  if(!pre.substring(pre.length-3,pre.length).match("\\\\" + escape_array[2]  + "\\\\" + escape_array[2] + "") && (pre.substring(pre.length-2,pre.length).match("\\\\" + escape_array[2]  + escape_array[3] + "")) ){
			    pre =pre.replace(/.{2}\$/,my_escapes[i]);

		 	    selObj.anchorNode.nodeValue = pre+post;
					t = pre.length +1;
			    return_cursor(selObj.focusNode, t);
			   return false; //Substitution is made. Should be able to exit here.
        }//No escape was found
      }// All my_escapes has been looped through.          

	    if(character){  ///User pressed character button
		    if(selObj.anchorNode == selObj.focusNode){ //Selected area DOES NOT cross nodes
		      pre  =  selObj.anchorNode.nodeValue.substring(0,cursorPos);		
	 				if(selObj.anchorOffset < selObj.focusOffset){ //user highlighted left to right.
						post = selObj.anchorNode.nodeValue.substring(selObj.focusOffset,selObj.focusNode.nodeValue.length);
					}else{
						post = selObj.anchorNode.nodeValue.substring(selObj.anchorOffset,selObj.anchorNode.nodeValue.length);
					}

			    selObj.focusNode.nodeValue= pre + character + post;
	        t= pre.length;
			    if(!myDiacritic[character]){

	    	    t++;
			    }
					t++;
			    return_cursor(selObj.focusNode, t); 
					return false;

		    }else{ //Selected area DOES cross nodes		


					if(sel_start =="left"){
					  post = selObj.focusNode.nodeValue.substring(selObj.focusOffset,selObj.focusNode.nodeValue.length);
					  temp_node = selObj.focusNode; //Need to copy this before removing selection
					}else{
						post = selObj.anchorNode.nodeValue.substring(selObj.anchorOffset,selObj.anchorNode.nodeValue.length);
						temp_node = selObj.anchorNode; //Need to copy this before removing selection
					}
          window.getSelection().deleteFromDocument(); 
				  temp_node.nodeValue= character+temp_node.nodeValue;


				  return_cursor(temp_node, 2);
					return false; 
		    }

				//Not sure why I have the next 4 lines of code
				alert("find and comment me");
		    post =  post.substring(window.getSelection().toString().length,post.length);
	      t=selObj.focusOffset;
        t+=2;	
        return_cursor(selObj.focusNode, t);
	    }
    }else{ //if cursorPos is less than zero, selection begins or ends at the start of a node, this is not an escape situation.

		  if(character){
		    if(selObj.anchorNode == selObj.focusNode){ //Selected area does NOT cross nodes. User click into empty text space, hit delete, then hit a button 
				selObj.focusNode.nodeValue = character;
			  	pre = "";
				}else{
				  var post = selObj.focusNode.nodeValue.substring(selObj.focusOffset,selObj.focusNode.nodeValue.length);
					selObj.focusNode.nodeValue = character+post;
					temp1= selObj.anchorNode;
					temp2= selObj.focusNode;
					window.getSelection().removeAllRanges();	
					var div = document.createRange();
					div.setStart(temp1, 0);
					div.setEnd(temp2, 0);
					window.getSelection().addRange(div);
	        window.getSelection().deleteFromDocument(); 
	        return_cursor(temp2, 2);
				}
      }
    }
  }
}



function return_cursor(the_node,len){ //the_node is 

  len--;

	window.getSelection().removeAllRanges();	
	var div = document.createRange();
	div.setStart(the_node, len);
	div.setEnd(the_node, len);
	window.getSelection().addRange(div);
	return false;
}


function roundNumber(rnum, rlength) { // Arguments: number to round, number of decimal places
  var newnumber = Math.round(rnum*Math.pow(10,rlength))/Math.pow(10,rlength);
  return newnumber;
}


function do_slider_zoom_onmousedown_stuff(){
  document.getElementById('current_scroll_percent').innerHTML = return_percent((document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop ),window.frames['iframe_scripture'].document.getElementById('pic').height);
  document.getElementById('current_scroll_width_percent').innerHTML = return_percent(document.getElementById('iframe_scripture').contentWindow.document.body.scrollLeft,window.frames['iframe_scripture'].document.getElementById('pic').width);
	document.getElementById('current_scroll_top').innerHTML=document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop;
	document.getElementById('current_scroll_height').innerHTML=document.getElementById('iframe_scripture').contentWindow.document.body.scrollHeight;
}




function do_key_down_stuff(event){

//make font sticky
if((document.getElementById('text_space').innerHTML.length<=0)&&(event.keyCode!=13)){
	if(!document.getElementById('select_font').value.match(/Font/)){
		document.getElementById('button_set_font').click();
	}
}
//	if(event.keyCode==36){ //Home key
//		document.getElementById('line_number').value =  1;
//		go_to_line();
//	} 
	if(event.keyCode==35){ //End key
		document.getElementById('line_number').value =  parent.side_bar.transcription.lines.length;
		go_to_line();
	}
	if(event.keyCode==33){ //page up = to to previous line
		if(parseInt(document.getElementById('line_number').value)>1){
		  document.getElementById('line_number').value--;
		  go_to_line();
	    }
	}
	if (event.keyCode == 38){
		scroll_iframe('arrow_up');
	 }

	 if (event.keyCode == 40){
	 	scroll_iframe('arrow_down');
     }

	if(event.keyCode==34){ //page down = go to next line
		if(parseInt(parent.side_bar.transcription.document.getElementById('total_lines').innerHTML)>parseInt(document.getElementById('line_number').value)){
		  document.getElementById('line_number').value++;
		  go_to_line();
		}
	}


	if(event.keyCode==220) { // back slash //This is probably legacy 6/22/10
		last_character_is_backslash =1;
	} else{
		 last_character_is_backslash=0; 
	} 

	if (event.keyCode == 13){ //return key //I believe that the contentEditable div sneakes tags in sometimes on its own.
	 	if(document.getElementById("text_space").innerHTML.match(/><br></i)){
	 		document.getElementById("text_space").innerHTML =document.getElementById("text_space").innerHTML.replace(/<br>/ig," ");
	 		document.getElementById('text_space_length').innerHTML="keyup empty with font tag";
	 	}

		 if(document.getElementById('text_space').innerHTML.length>0){
		 	if(!document.getElementById('text_space').innerHTML.match(/<br>/)){
			 	send_text();
			 }
		 }
	}	

}


function do_key_up_stuff(event){

	if(document.getElementById('text_space').innerHTML.match(/(<br>|<\\/br>)/)){
		document.getElementById('text_space').innerHTML = document.getElementById('text_space').innerHTML.replace(/(<br>|<\\/br>)/g,"");
		document.getElementById('focus_text_space').focus();document.getElementById('focus_text_space').click();
		return false;
	}

	if (event.keyCode == 37){
		scroll_iframe_left_or_right('arrow_left');
	}
	if (event.keyCode == 39){
		scroll_iframe_left_or_right('arrow_right');
	}


	if(event.keyCode==8 ){ //back space 
		if(document.getElementById('text_space').innerHTML.length==0){
			document.getElementById('text_space').innerHTML="<font face='Charis Sil'></font>"; //This is just for the current books
			setTimeout("document.getElementById('focus_text_space').focus();document.getElementById('focus_text_space').click();",400);
			return false;
		}
	}
	if (event.keyCode == 13){ //Return key was pressed
	  document.getElementById('focus_text_space').focus();
	 	document.getElementById('focus_text_space').click();
	 	if(document.getElementById('should_scroll').innerHTML=='yes'){
	 		scroll_iframe('standard');
	 		document.getElementById('text_space').innerHTML='';

	 	}
	 	document.getElementById('focus_text_space').focus();
	 	document.getElementById('focus_text_space').click(); 
		if(document.getElementById('should_scroll').innerHTML=='yes'){
			document.getElementById('text_space').innerHTML=='';
		}
	}		
}
  
function prepare_set_font(){
	document.getElementById('button_set_font').focus();	
	document.getElementById('button_set_font').click();
}



function xmlhttpPost(strURL,query_string) {

  var self = this;
  // Mozilla/Safari
  if (window.XMLHttpRequest) {
    self.xmlHttpReq = new XMLHttpRequest();
  }
  // IE
  else if (window.ActiveXObject) {
    self.xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
  }
  self.xmlHttpReq.open('POST', strURL, true);
  self.xmlHttpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  self.xmlHttpReq.onreadystatechange = function() {
    if (self.xmlHttpReq.readyState == 4) {
      if(self.xmlHttpReq.responseText.match(/Software/)){
        alert(self.xmlHttpReq.responseText);
	  }
    }
  }

  if(strURL.match(/realign/)){

    self.xmlHttpReq.send(query_string);  	
  } else{
    self.xmlHttpReq.send(getquerystring());  	
  } 

  document.getElementById('last_page').innerHTML= "last edit: " + document.getElementById('select_scripture').value;
}

function getquerystring() {
    var form     = document.forms['form_transcription'];
END

for(@attributes){
	print qq(var $_	= form.$_.value;\n);
}

print <<END;

var text_line = form.text_line.value;

	text_line = text_line.replace(/&/g,"ampersandxxx");
	text_line = text_line.replace(/;/g,"semicolonxxx");

  qstr = 'file_name=' + escape(file_name) + 
    "&text_line="+ text_line + 
    "&x1="+ escape(x1) +  
    "&y1="+ escape(y1) + 
    "&x2="+ escape(x2) +     		    		   		
	"&y2="+ escape(y2) + 
	"&book="+ escape(book) + 
    "&image_width_px="+ escape(image_width_px) +  
    "&image_height_px="+ escape(image_height_px) + 
    "&line_height="+ escape(line_height) +     		    		   		
	"&font_size="+ escape(font_size) +
    "&kern="+ escape(kern) +  
    "&col="+ escape(col) +  
    "&row="+ escape(row) +      
    "&rotation="+ escape(rotation) + 
    "&box_height="+ escape(box_height) + 
	"&num="+ escape(num) ;  // NOTE: no '?' before querystring

    return qstr;
    

}





function edit_json(){
	temp_line_num = parseInt(document.getElementById('line_number').value);


END
	for(@attributes){	
		print qq(parent.side_bar.transcription.lines[temp_line_num].$_ = document.getElementById('$_').value;\n);
	}
	print <<END;
}


      
function change_xml_file() {
  if (window.XMLHttpRequest) {              
    AJAX=new XMLHttpRequest();              
  } else {                                  
    AJAX=new ActiveXObject("Microsoft.XMLHTTP");
  }
  if (AJAX) {
    AJAX.open("GET", "image.pl?image_name="+document.getElementById('select_scripture').value, false);
     AJAX.send(null);
     return AJAX.responseText;                                         
  } else {
     return false;
  }                                             
}

function fetch2() {  
  if (window.XMLHttpRequest) {              
    AJAX=new XMLHttpRequest();              
  } else {                                  
    AJAX=new ActiveXObject("Microsoft.XMLHTTP");
  }
  var timestamp = new Date();
  if (AJAX) {
    AJAX.open("GET", "image.pl?image_name="+document.getElementById('select_scripture').value, false);
    AJAX.send();
  document.getElementById('call_status').innerHTML=(AJAX.responseText);  
	

//	setTimeout("document.getElementById('btn_correct_angle').focus();document.getElementById('btn_correct_angle').click();",3000);
    return false;                                         
  } else {
     return false;
  }                                             
}  



function update_xml_file() {  
  if (window.XMLHttpRequest) {              
    AJAX=new XMLHttpRequest();              
  } else {                                  
    AJAX=new ActiveXObject("Microsoft.XMLHTTP");
  }
  var timestamp = new Date();
  if (AJAX) {

var string= "fix_xml.pl?file_name="
+document.getElementById('select_scripture').value 
+ "&x_1=" + Math.round(document.getElementById('Mouse1X').value)
+ "&y_1=" + Math.round(document.getElementById('Mouse1Y').value)
+ "&view_width=" + Math.round(document.getElementById('view_width').value)
+ "&row_top=" + Math.round(document.getElementById('row_top').value)
+ "&row_bottom=" + Math.round(document.getElementById('row_bottom').value)
+ "&realign_x=" + Math.round(document.getElementById('realign_x').value)
+ "&realign_y=" + Math.round(document.getElementById('realign_y').value)
+ "&realign_row=" + Math.round(document.getElementById('realign_row').value)
+ "&realign_number=" + Math.round(document.getElementById('line_number').value)
+ "&Mouse2X=" + Math.round(document.getElementById('Mouse2X').value)
+ "&Mouse2Y=" + Math.round(document.getElementById('Mouse2Y').value)
+ "&book=" + document.getElementById('select_book').value
+ "&new_font_size="+ document.getElementById('new_font_size').value
+ "&new_line_height=" + document.getElementById('new_line_height').value
+ "&new_kern=" + document.getElementById('new_kern').value;
END

for($i=2;$i<20;$i++){
	print qq(if(document.getElementById('x_' + $i).value){string = string + "&x_$i=" + Math.round(document.getElementById('x_' + $i).value)});
	print qq(if(document.getElementById('y_' + $i).value){string = string + "&y_$i=" + Math.round(document.getElementById('y_' + $i).value)});
#	print qq(if(document.getElementById('x_' + $i).value){string = string + "&$i=" + Math.round(document.getElementById($i).value)});
}
print ";";
print <<END;


    AJAX.open("GET",string , false);
    AJAX.send();
    if(AJAX.responseText.length>2){
   alert(AJAX.responseText)
   }
	document.getElementById('last_page').innerHTML= "last edit: " + document.getElementById('select_scripture').value;

    return false;                                         
  } else {
     return false;
  }                                             
}  




function do_initial_stuff(){
	set_font_slider_options("roman");
	document.getElementById('text_space').innerHTML="";
	document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop = 2000000; //probably can get rid of this since have scrollHeight
	max_scrollTop = document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop;
	document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop = 0;

	document.getElementById('focus_text_space').click();

	var lF = document.getElementById('iframe_scripture').contentWindow;
	if(window.pageXOffset!=undefined){ //opera, firefox,& gecko browsers
		lF.onscroll = function(){
			document.getElementById('scroll_position_h').innerHTML= lF.pageXOffset;
			document.getElementById('scroll_position_v').innerHTML= lF.pageYOffset;
			scroll_position = lF.pageYOffset;
			scroll_position_h = lF.pageXOffset;
		}
	}

}



function send_text(skip_line_num_change){
  //calculates values for x1, x2, and y1 according to normal image.
  var image_height_px  		   	  = window.frames['iframe_scripture'].document.getElementById('pic').height;
  var distance_from_screen_middle = iframe_scripture.Zbrowse.height()/2;
  var test_distance 			  = distance_from_screen_middle;
  var scroll_top_px  			  = document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop;
  var percent_to_decrease_recorded_scroll_height  = 100 + (((document.getElementById('expanded_height').innerHTML - image_height_px )/ image_height_px)*100);
  distance_from_screen_middle =  ((percent_to_decrease_recorded_scroll_height * distance_from_screen_middle)/100)+ parseFloat(document.getElementById('text_space').style.height.replace(/px/,""));
  y1 = ((percent_to_decrease_recorded_scroll_height * scroll_top_px)/100)+distance_from_screen_middle;
  y1 = roundNumber(((percent_to_decrease_recorded_scroll_height * scroll_top_px)/100)+distance_from_screen_middle,0)+1;
  y1-= parseInt(document.getElementById('text_space').style.height.replace(/px/,""));
  var image_original_width_px = document.getElementById('first_width').innerHTML; 
  var image_width_px  		= document.getElementById('iframe_scripture').contentWindow.document.getElementById('pic').width;
  var scroll_left_px  		= document.getElementById('iframe_scripture').contentWindow.document.body.scrollLeft;
  var percent_to_decrease_recorded_scroll_width  = 100 + (((image_original_width_px -image_width_px )/ image_width_px)*100);
  x1 = roundNumber((percent_to_decrease_recorded_scroll_width * scroll_left_px)/100,0);	
  var x2_increment = (percent_to_decrease_recorded_scroll_width * document.getElementById('iframe_scripture').contentWindow.document.body.clientWidth)/100;
  y1 -=300; //all that needs to be done to apply to non buffered image.
  var x2 = roundNumber((x1 + x2_increment),0) ;
  var y2 = y1;

  document.form_transcription.image_height_px.value = document.getElementById('first_height').innerHTML;
  document.form_transcription.image_width_px.value  = image_original_width_px;
  document.form_transcription.x2.value    = x2;
  document.form_transcription.y2.value    = y2;
  document.form_transcription.y1.value    = y1;
  document.form_transcription.x1.value    = x1;
  document.form_transcription.book.value  = document.getElementById('select_book').value;
  //'<div>text</div>' somehow slips in sometimes. Not sure why.
  document.getElementById('text_space').innerHTML = document.getElementById('text_space').innerHTML.replace(\/<div>\/,"");
  document.getElementById('text_space').innerHTML = document.getElementById('text_space').innerHTML.replace(\/<\\/div>\/,"");
  document.form_transcription.file_name.value	    = document.getElementById('select_scripture').value;
  document.form_transcription.text_line.value	    = document.getElementById('text_space').innerHTML.replace(/"/g,"'");
  document.form_transcription.rotation.value      = document.getElementById('rotation').innerHTML;
  document.form_transcription.box_height.value    = document.getElementById('text_space').style.height.replace(/px/,"");
  document.form_transcription.num.value  		      = document.getElementById('line_number').value;
  //document.form_transcription.font_size.value  		  = document.getElementById('text_space').style.fontSize;

  var base = parseInt(document.getElementById('original_font_size').innerHTML.replace(/px/,""));
  var new_amount = parseInt(document.getElementById('auto_expanded_font_size').innerHTML.replace(/px/,""));
  var font_ratio =  ((base/new_amount)*100);

  var new_font_size = Math.round((parseInt(document.getElementById('text_space').style.fontSize.replace(/px/,"")) * font_ratio)/100) + "px";

  document.form_transcription.font_size.value = new_font_size;
  document.form_transcription.line_height.value  		  = document.getElementById('text_space').style.lineHeight.replace(/pt/,"");
  document.form_transcription.kern.value  		  = document.getElementById('text_space').style.letterSpacing.replace(/pt/,"");;
  var current_line_num = parseInt(document.getElementById('line_number').value);
 //light up div attributes

  parent.side_bar.transcription.document.getElementById(parseInt(document.getElementById('line_number').value)).innerHTML=current_line_num + ". " + document.getElementById('text_space').innerHTML.replace(/"/g,"'");
  parent.side_bar.transcription.document.getElementById(parseInt(document.getElementById('line_number').value)).style.display="inline"; 
  parent.side_bar.transcription.document.getElementById(parseInt(document.getElementById('line_number').value)).setAttribute('x1',x1);
  parent.side_bar.transcription.document.getElementById(parseInt(document.getElementById('line_number').value)).setAttribute('y1',y1);
  parent.side_bar.transcription.document.getElementById(parseInt(document.getElementById('line_number').value)).setAttribute('x2',x2);
  parent.side_bar.transcription.document.getElementById(parseInt(document.getElementById('line_number').value)).setAttribute('y2',y2);
//  parent.side_bar.transcription.document.getElementById(parseInt(document.getElementById('line_number').value)).setAttribute('line_height',line_height);
  parent.side_bar.transcription.document.getElementById(parseInt(document.getElementById('line_number').value)).setAttribute('line_height',document.form_transcription.line_height.value);
  parent.side_bar.transcription.document.getElementById(parseInt(document.getElementById('line_number').value)).setAttribute('font_size',new_font_size);
  parent.side_bar.transcription.document.getElementById(parseInt(document.getElementById('line_number').value)).setAttribute('box_height',document.form_transcription.box_height.value);
  parent.side_bar.transcription.document.getElementById(parseInt(document.getElementById('line_number').value)).setAttribute('kern',document.form_transcription.kern.value);

  document.getElementById('btn_ajax').click();
  if(!skip_line_num_change){
	document.getElementById('text_space').innerHTML="";
	current_line_num++;
	document.getElementById('line_number').value = current_line_num;
	document.getElementById('line_number').value = current_line_num;
	go_to_line();	
	setTimeout("document.getElementById('btn_eliminate_line_breaks').click();",500);
  }
}

	function scroll_iframe(direction){
		scroll_position= calculate_scroll_length(direction);
		document.getElementById('iframe_scripture').contentWindow.scrollTo(document.getElementById('iframe_scripture').contentWindow.document.body.scrollLeft,scroll_position);
	}

	function scroll_iframe_left_or_right(direction){
		if (!document.getElementById('text_space').innerHTML.match(/^\s*\$/)){

		}else{//If text space is empty, shift the box right or left. Currently must click one time per pixel. 

			scroll_position= calculate_scroll_length(direction);
			document.getElementById('iframe_scripture').contentWindow.scrollTo(scroll_position,document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop);
		}
	}
  	function calculate_scroll_length(direction){
  		if (direction == "standard"){
			unit = document.getElementById('text_space').style.height.match(/^\\d+/);
		}
		if (direction == "arrow_down"){
			unit = 1;
		}
		if (direction == "arrow_up"){
			unit = -1;
		}
		if (direction == "arrow_right"){
			unit = 1;
		}
		if (direction == "arrow_left"){
			unit = -1;
		}

		if(direction == "arrow_left" || direction == "arrow_right"){		
			
			scroll_position = document.getElementById('iframe_scripture').contentWindow.document.body.scrollLeft + parseInt(unit);

		}else{
			scroll_position = document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop + parseInt(unit);
		}		
		return scroll_position;
	}




function doFormat(cmd) {
        document.execCommand(cmd, null, null);
 }
scroll_span = 20;



function set_font_slider_options(font_type){
	if(font_type == "roman"){
		slider_font_percentage_for_height = 125;
		slider_font_percentage_for_line_height = 100;
	}
	if(font_type == "ipa"){
		slider_font_percentage_for_height = 135;
		slider_font_percentage_for_line_height = 115;
	}	
	if(font_type == "sea"){
		slider_font_percentage_for_height = 175;
		slider_font_percentage_for_line_height = 150;
	}


	current_slider_height 	   = (\$("#slider_font_size").slider('value') *  slider_font_percentage_for_height     )/100;
	current_slider_line_height = (\$("#slider_font_size").slider('value') *  slider_font_percentage_for_line_height)/100;

//set sliders		
	\$("#slider_height").slider('value',current_slider_height);
	\$("#slider_line_height").slider('value',current_slider_line_height);		

//set form
	document.form_transcription.box_height.value = current_slider_height +"px";

	document.form_transcription.line_height.value 	 = current_slider_line_height +"px";

//set div attributes


	\$("#text_space").css('height', current_slider_height + "px");	
	\$("#text_space").css('lineHeight', current_slider_line_height + "px");


//set display attributes
	\$("#input_box_display").html(current_slider_height +"px");
	\$("#line_height_display").html(current_slider_line_height +"px");
	\$("#font_size_display").html(\$("#slider_font_size").slider('value') +"px");

}	



	\$(function() {
		
		\$("#slider_font_size").slider({
			orientation: "horizontal",
			range: "min",
			min: 0,
			max: 200,
			value: 20,
			slide: function(event, ui) {
//document.form_transcription.font_size.value = ui.value +"px";
				\$("#font_size_display").html(ui.value+ "px");
				\$("#text_space").css('font-size', ui.value);
			}
		});


		\$("#slider_button_size").slider({
			orientation: "horizontal",
			range: "min",
			min: 0,
			max: 50,
			value: 20,
			slide: function(event, ui) {


			document.getElementById('button_div').style.fontSize=ui.value+"px";
			document.getElementById('generic_button_div').style.fontSize=ui.value+"px";
	//		changecss('.exampleA','font-size',ui.value + 'px');
	
			}
		});



		\$("#slider_font_special").slider({
			orientation: "horizontal",
			range: "min",
			min: 0,
			max: 200,
			value: 20,
			slide: function(event, ui) {

				special_line_height_value = (ui.value*slider_font_percentage_for_line_height)/100;
				special_height_value      = (ui.value*slider_font_percentage_for_height)/100;
	

				document.form_transcription.box_height.value = special_height_value +"px";
				document.form_transcription.line_height.value = special_line_height_value +"px";


				\$("#font_special_display").html(ui.value + "px");
				\$("#font_size_display").html(ui.value + "px");
				\$("#slider_font_size").slider('value',ui.value);
				
				\$("#text_space").css('font-size', ui.value + "px");	
							
				\$("#line_height_display").html(special_line_height_value + "px");
				\$("#slider_line_height").slider('value',special_line_height_value);				
				\$("#text_space").css('line-height', special_line_height_value + "px");


				\$("#input_box_display").html(special_height_value + "px");
				\$("#slider_height").slider('value',special_height_value);				
				\$("#text_space").css('height', special_height_value + "px");


			}
		});		

		

		\$("#slider_height").slider({
			orientation: "horizontal",
			range: "min",
			min: 0,
			max: 200,
			value: 20,
			slide: function(event, ui) {
			document.form_transcription.box_height.value = ui.value +"px";

				\$("#input_box_display").html(ui.value + "px");
				\$("#text_space").css('height', ui.value);		
			}
		});
		
		
		\$("#slider_line_height").slider({
			orientation: "horizontal",
			range: "min",
			min: 0,
			max: 200,
			value: 20,
			slide: function(event, ui) {
document.form_transcription.line_height.value = ui.value +"px";
				\$("#line_height_display").html(ui.value + "px");
				\$("#text_space").css('line-height', ui.value + "px");
			}
		});		

		\$("#slider_kern").slider({
			orientation: "horizontal",
			range: "min",
			min: 0,
			max: 100,
			step: .2,
			value: 0,
			slide: function(event, ui) {
document.form_transcription.kern.value = ui.value +"px";
				\$("#kern_display").html(ui.value + "px");
				\$("#text_space").css('letter-spacing', ui.value + "px");
			}
		});		

		
			\$("#slider_zoom").slider({
			orientation: "horizontal",
			range: "min",
			min: 1,
			max: 350,
			value: 100,
			slide: function(event, ui) {

			var current_percent = document.getElementById('current_scroll_percent').innerHTML;
			var current_width_percent = document.getElementById('current_scroll_width_percent').innerHTML;
			var percent_increase_scroll_top =0;// (document.getElementById('iframe_scripture').contentWindow.document.body.scrollHeight 5)/100;
			var percent_increase_scroll_left = 0;
			
			if (ui.value > Math.round(document.getElementById('zoom_display').innerHTML.replace(/%/,""))){


			document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop  = ((current_percent * window.frames['iframe_scripture'].document.getElementById('pic').height ) /100 )+ (percent_increase_scroll_top);
			document.getElementById('iframe_scripture').contentWindow.document.body.scrollLeft = ((current_width_percent * window.frames['iframe_scripture'].document.getElementById('pic').width ) /100 )+  (percent_increase_scroll_left);

			}else{

			document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop  = ((current_percent * window.frames['iframe_scripture'].document.getElementById('pic').height ) /100 )- (percent_increase_scroll_top);
			document.getElementById('iframe_scripture').contentWindow.document.body.scrollLeft  = ((current_width_percent * window.frames['iframe_scripture'].document.getElementById('pic').width ) /100 )- (percent_increase_scroll_left);
			}
//			setTimeout("\$('#iframe_scripture').contents().find('#pic').rotateRight(360);",20);
			var prechange_height = window.frames['iframe_scripture'].document.getElementById('pic').width;
			var percent_increase_px = (document.getElementById('first_width').innerHTML * ui.value)/100;


	 percentage_of_expansion_height = (window.frames['iframe_scripture'].document.getElementById('pic').height/parseInt(document.getElementById('original_expansion_height').innerHTML))*100;


	if(document.getElementById('line_number').value.match(/\d/)){
		document.getElementById('text_space').style.fontSize = (parent.side_bar.transcription.document.getElementById(document.getElementById('line_number').value).getAttribute('font_size').replace(/px/,'')* percentage_of_expansion_height)/100 + "px";
		document.getElementById('text_space').style.lineHeight = (parent.side_bar.transcription.document.getElementById(document.getElementById('line_number').value).getAttribute('line_height').replace(/px/,'')* percentage_of_expansion_height)/100 + "px";
		document.getElementById('text_space').style.height = (parent.side_bar.transcription.document.getElementById(document.getElementById('line_number').value).getAttribute('box_height').replace(/px/,'')* percentage_of_expansion_height)/100 + "px";
	}


		window.frames['iframe_scripture'].document.getElementById('pic').width = percent_increase_px
				\$("#zoom_display").html(ui.value + "%" );
				\$("#scroll_top_display").html(document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop);
				\$("#scroll_height_display").html(document.getElementById('iframe_scripture').contentWindow.document.body.scrollHeight);
			}
		});				



//           \$('h1.editableText, p.editableText').editableText({
//				newlinesEnabled: true
//			});
//			
//			\$.editableText.defaults.newlinesEnabled = true;
//
//			\$('div.editableText').editableText();
//			
//			\$('.editableText').change(function(){
//				var newValue = \$(this).html();
//			});
	});
	


function go_to_line(){
  var requested_line_number = document.getElementById('line_number').value;
  \$("#line_number_display").html(requested_line_number);

  var next_number = parseInt(requested_line_number) ;
  if(parent.side_bar.transcription.document.getElementById(requested_line_number).style.display=="none"){
    \$("#should_scroll").html('yes');
  }else{
		\$("#should_scroll").html('no');
	}

  //set style attributes
  document.getElementById('font_size_display').innerHTML   =  parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('font_size').replace(/(px|\\s)/,"") +"px";
  document.getElementById('input_box_display').innerHTML   =  parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('box_height').replace(/(px|\\s)/,"") +"px";
  document.getElementById('line_height_display').innerHTML =  parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('line_height').replace(/(px|\\s)/g,"") +"px";
  \$("#slider_font_size").slider('value', parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('font_size').replace(/(px|\\s)/g,""));
  \$("#slider_height").slider('value', parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('box_height').replace(/(px|\\s)/g,""));
  \$("#slider_line_height").slider('value', parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('line_height').replace(/(px|\\s)/g,""));
  if(parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('kern')){
	  \$("#slider_kern").slider('value', parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('kern').replace(/(px|\\s)/g,""));
	  document.getElementById('text_space').style.letterSpacing = parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('kern').replace(/(px|\\s)/g,"") +"px";
  }
  document.getElementById('text_space').style.fontSize      = parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('font_size').replace(/(px|\\s)/g,"") +"px";
  document.getElementById('original_font_size').innerHTML   = parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('font_size').replace(/(px|\\s)/g,"");
  document.getElementById('text_space').style.lineHeight    = parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('line_height').replace(/(px|\\s)/g,"") +"px";
  document.getElementById('text_space').style.height        = parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('box_height').replace(/(px|\\s)/g,"") +"px";
  document.getElementById('text_space').style.textAlign     = parent.side_bar.transcription.document.getElementById('text_align').value;

  document.getElementById('row').value = parseInt(parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('row'));
  document.getElementById('col').value = parseInt(parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('col'));
	
//focus window on line in image
  set_test_position(parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('x1'),parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('y1'),parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('x2'),parent.side_bar.transcription.document.getElementById(requested_line_number).getAttribute('y1'));

//set text
  var prep_text = parent.side_bar.transcription.document.getElementById(requested_line_number).innerHTML;

  prep_text = prep_text.replace(/<br>\$/,"");
  prep_text = prep_text.replace(/^\\d+./,"");
  document.getElementById('text_space').innerHTML = prep_text;
// The next line might just be needed when a new image with top and bottom buffers are added
   setTimeout("document.getElementById('btn_focus').focus();document.getElementById('btn_focus').click();",1000);
  if(!parent.side_bar.transcription.document.getElementById(requested_line_number).style.backgroundColor.match(/yellow/)){
    unpaint_divs();
    parent.side_bar.transcription.document.getElementById(requested_line_number).style.backgroundColor="yellow";
    scroll_to_line_in_payne();
  }
  document.getElementById('focus_text_space').click(); //place cursor at beginning of newly arrived to line
}

//unpaint all divs before changing a single one to yellow
function unpaint_divs(){
	var elements = parent.side_bar.transcription.document.getElementsByTagName('div');
	for (var i = 0; i < elements.length; i++) { 
	    status = elements[i].style.backgroundColor="white";
 
	}
}

function scroll_to_line_in_payne(){
//Scroll to line in upper right payne. 
		parent.side_bar.transcription.document.getElementById('sniper').setAttribute('href','transcription.pl#'+parseInt(document.getElementById('line_number').value));
		parent.side_bar.transcription.document.getElementById('sniper').click();

}

function set_test_position(x1,y1,x2, y2){

	set_highlight_in_scripture_small(x1, y1,x2, y2);
	//add 300 to the y points so they fit in the buffer version of the image
	y1 = parseInt(y1)+300; //NEEDED for buffered images

	window.frames['iframe_scripture'].document.getElementById('pic').width = document.getElementById('first_width').innerHTML;
	percent_of_frame_width = (window.frames['iframe_scripture'].document.getElementById('pic').width * 100)/ window.frames['iframe_scripture'].document.body.clientWidth;
	percent_of_image_width = (x2 *100) / window.frames['iframe_scripture'].document.getElementById('pic').width;
	area_percent_of_frame_width = ((x2 - x1) * 100) /window.frames['iframe_scripture'].document.body.clientWidth;
	times_to_zoom = 100 / area_percent_of_frame_width;

	window.frames['iframe_scripture'].document.getElementById('pic').width = (window.frames['iframe_scripture'].document.getElementById('pic').width * times_to_zoom);
	iframe_height = parseInt(document.getElementById('iframe_scripture').height.replace(/px/,""));
	document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop = ((y1 * times_to_zoom)-((iframe_height/2)));
	document.getElementById('iframe_scripture').contentWindow.document.body.scrollLeft = (x1 * times_to_zoom);

	\$('#slider_zoom').slider('value',parseInt(times_to_zoom*100));	
	document.getElementById('zoom_display').innerHTML = parseInt(times_to_zoom*100)+"%";
	//THIS IS TEMPORARY RESIZE SPECIFIC TO ONE BOOK -mike 2.6.10
////	document.getElementById('text_space').style.fontSize = Math.round((times_to_zoom * 88))+"px";	
////	document.getElementById('auto_expanded_font_size').innerHTML = Math.round((times_to_zoom * 88))+"px";	

	var recorded_font_size = parent.side_bar.transcription.document.getElementById(document.getElementById('line_number').value).getAttribute('font_size').replace(/(px|\\s)/g,"");
	document.getElementById('text_space').style.fontSize = Math.round((times_to_zoom * recorded_font_size))+"px";	
	document.getElementById('auto_expanded_font_size').innerHTML = Math.round((times_to_zoom * recorded_font_size));	
	document.getElementById('display_times_to_zoom').innerHTML=times_to_zoom;
}


function set_highlight_in_scripture_small(point_2_x,point_2_y,point_1_x, point_1_y){
//alert(point_2_y + " " + point_2_x + " " + point_1_x + " " +  point_1_y);
	image_original_height_px = document.getElementById('first_height').innerHTML;

	rate_to_reduce_height_of_highlight = (parent.side_bar.scripture_small.document.getElementById('pic').height/image_original_height_px)*100;
	rate_to_reduce_width_of_highlight 		 = (parent.side_bar.scripture_small.document.getElementById('pic').width/document.getElementById('first_width').innerHTML)*100; 

	scripture_small_2_y=((rate_to_reduce_height_of_highlight*point_2_y)/100);

	scripture_small_2_x=(rate_to_reduce_width_of_highlight*point_2_x)/100;
	parent.side_bar.scripture_small.document.getElementById('highlight_strip').style.top = scripture_small_2_y;	
	parent.side_bar.scripture_small.document.getElementById('highlight_strip').style.left = scripture_small_2_x;	
	var highlight_width_orig = point_1_x - point_2_x;
	amount_to_reduce_highlight_width = (rate_to_reduce_width_of_highlight * highlight_width_orig)/100;
	parent.side_bar.scripture_small.document.getElementById('highlight_strip').style.width = (highlight_width_orig * rate_to_reduce_width_of_highlight)/100;	
}


function expand_or_shrink(action, height_or_width){
	
	var percent_increase_px = (window.frames['iframe_scripture'].document.getElementById('pic').width * 5)/100;
	var \$currentIFrame = \$('#iframe_scripture'); 


//	percent_of_frame_width = (window.frames['iframe_scripture'].document.getElementById('pic').width / window.frames['iframe_scripture'].document.body.clientWidth) * 100;
//	percent_of_frame_width = percent_of_frame_width+"%";
//	window.frames['iframe_scripture'].document.getElementById('pic').style.width = percent_of_frame_width;

	if(action == "expand"){window.frames['iframe_scripture'].document.getElementById('pic').width += percent_increase_px;}
	if(action == "shrink"){window.frames['iframe_scripture'].document.getElementById('pic').width -= percent_increase_px; }
	
}	


function do_image_change_stuff(){

  document.getElementById('call_status').innerHTML="please stand by";

//uncomment this for former normal version
//\$("#slider_zoom").slider('value',100);			
//	document.getElementById('zoom_display').innerHTML=100;

//	setTimeout('fetch2();',100);

  //get Height and Width of unexpanded image
  document.getElementById('first_width').innerHTML     = document.getElementById('select_scripture').options[document.getElementById('select_scripture').selectedIndex].getAttribute('x_value');
  document.getElementById('first_height').innerHTML    = document.getElementById('select_scripture').options[document.getElementById('select_scripture').selectedIndex].getAttribute('y_value');

	//save height of expanded image by adding 600px to original image height
  document.getElementById('expanded_height').innerHTML = parseInt(document.getElementById('select_scripture').options[document.getElementById('select_scripture').selectedIndex].getAttribute('y_value')) + $height_expansion_increment;

	//Set params in form on upper right frame
  parent.side_bar.transcription.document.form_transcription.file_name.value=document.getElementById('select_scripture').value; 
  parent.side_bar.transcription.document.form_transcription.book.value=document.getElementById('select_book').value; 

	//Set src for small payne image, same for iframe image plus width. Then submit right payne form to get lines, and then scroll down iframe image
  parent.frames['side_bar'].frames['scripture_small'].document.getElementById('pic').src = 'books/' + document.getElementById('select_book').value + '/images/' + document.getElementById('select_scripture').value;
  window.frames['iframe_scripture'].document.getElementById('pic').src = 'books/' + document.getElementById('select_book').value + '/images_expanded/' + document.getElementById('select_scripture').value;
  window.frames['iframe_scripture'].document.getElementById('pic').width=  document.getElementById('first_width').innerHTML;
  parent.side_bar.transcription.document.form_transcription.submit(0);
  setTimeout("document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop=300;",1000);
}




function set_point(point_num){
	if(point_num == "first"){
		\$('#Mouse1X').val(Math.round(parent.side_bar.scripture_small.document.getElementById('mouseX').innerHTML));
		\$('#Mouse1Y').val(Math.round(parent.side_bar.scripture_small.document.getElementById('mouseY').innerHTML));
		return false;
	}
	if(point_num == "second"){
		\$('#Mouse2X').val(Math.round(parent.side_bar.scripture_small.document.getElementById('mouseX').innerHTML));
		\$('#Mouse2Y').val(Math.round(parent.side_bar.scripture_small.document.getElementById('mouseY').innerHTML));
		return false;
	}
	if(point_num=="top"){
		\$('#row_top').val(Math.round(parent.side_bar.scripture_small.document.getElementById('mouseY').innerHTML));
		return false;
	}
	if(point_num=="bottom"){
		\$('#row_bottom').val(Math.round(parent.side_bar.scripture_small.document.getElementById('mouseY').innerHTML));
		document.getElementById('common_row_height').innerHTML=(parseInt(document.getElementById('row_bottom').value)-parseInt(document.getElementById('row_top').value));
		return false;

	}
	document.getElementById('x_' +point_num).value=Math.round(parent.side_bar.scripture_small.document.getElementById('mouseX').innerHTML);
	document.getElementById('y_' +point_num).value=Math.round(parent.side_bar.scripture_small.document.getElementById('mouseY').innerHTML);
}

function click_cancel_reset(){
	document.getElementById('btn_realign').style.display="inline";
	document.getElementById('reset_page').style.display="inline";
	document.getElementById('cancel_reset_page').style.display="none";
	document.getElementById('xml_panel').style.display="none";
	document.getElementById('top_panel').style.display="inline";
	document.getElementById('mid_panel').style.display="inline";


	document.getElementById('div_scripture').style.top="200px";
	document.getElementById('div_scripture').style.display="inline";
	document.getElementById('panel_char_buttons').style.display="inline";	
	parent.document.body.cols = "60%,40%";
	parent.side_bar.document.body.rows = "50%,50%";
	
}

function click_fix_xml(){

  update_xml_file(); //creates query string a submits params via ajax

  document.getElementById('div_scripture').style.display="inline";
  document.getElementById('xml_panel').style.display="none";
  parent.side_bar.transcription.document.form_transcription.file_name.value=document.getElementById('select_scripture').value; 
  parent.side_bar.transcription.document.form_transcription.book.value=document.getElementById('select_book').value; 
  parent.side_bar.transcription.document.form_transcription.submit(0);
  document.getElementById('cancel_reset_page').click();
}


function click_reset_page(){
	document.getElementById('btn_realign').style.display="none";
	document.getElementById('div_scripture').style.display="none";
	document.getElementById('reset_page').style.display="none";
	document.getElementById('cancel_reset_page').style.display="inline";	
	document.getElementById('top_panel').style.display="none";
	document.getElementById('mid_panel').style.display="none";
	document.getElementById('div_scripture').style.top="300px";
	document.getElementById('panel_char_buttons').style.display="none";	
	document.getElementById('xml_panel').style.display="inline";
	parent.document.body.cols = "20%,80%";
	parent.side_bar.document.body.rows = "20%,80%";
}




function eliminate_line_breaks(){
	document.getElementById('text_space').innerHTML= document.getElementById('text_space').innerHTML.replace(/<div.+?<br>.+?div>/," ");	
}


function realign(){
  var line_num = document.getElementById('line_number').value;
  area_percent_of_frame_width = ((parent.side_bar.transcription.document.getElementById(line_num).getAttribute('x2') - parent.side_bar.transcription.document.getElementById(line_num).getAttribute('x1')) * 100) /window.frames['iframe_scripture'].document.body.clientWidth;
  times_to_zoom = 100 / area_percent_of_frame_width;
  var new_y1 = document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop + (iframe_scripture.Zbrowse.height()/2);
  var new_x1 = document.getElementById('iframe_scripture').contentWindow.document.body.scrollLeft;
	
  new_y1= Math.round((new_y1/times_to_zoom)-300);
  new_x1= Math.round((new_x1/times_to_zoom));
  document.getElementById('realign_x').value = new_x1;
  document.getElementById('realign_y').value = new_y1;
  document.getElementById('realign_row').value = parent.side_bar.transcription.document.getElementById(parseInt(document.getElementById('line_number').value)).getAttribute('row');
  document.getElementById('div_realign_number').innerHTML=document.getElementById('line_number').value;
  document.getElementById('btn_fix_xml').click();
}


function realign_o(){
  var line_num = document.getElementById('line_number').value;
  area_percent_of_frame_width = ((parent.side_bar.transcription.document.getElementById(line_num).getAttribute('x2') - parent.side_bar.transcription.document.getElementById(line_num).getAttribute('x1')) * 100) /window.frames['iframe_scripture'].document.body.clientWidth;
  times_to_zoom = 100 / area_percent_of_frame_width;
  var old_y1 = Math.round((300+ Math.round(parent.side_bar.transcription.document.getElementById(line_num).getAttribute('y1')))*times_to_zoom);
  var new_y1 = document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop + (iframe_scripture.Zbrowse.height()/2);
  var old_x1 = Math.round((Math.round(parent.side_bar.transcription.document.getElementById(line_num).getAttribute('x1')))*times_to_zoom);
  var new_x1 = document.getElementById('iframe_scripture').contentWindow.document.body.scrollLeft;
  var amount_to_increase_y = new_y1-old_y1;	  
  var amount_to_increase_x = new_x1-old_x1;
  realign_divs(parseInt(parent.side_bar.transcription.document.getElementById(line_num).getAttribute('x1')),Math.round(amount_to_increase_x/times_to_zoom),parseInt(parent.side_bar.transcription.document.getElementById(line_num).getAttribute('y1')),Math.round(amount_to_increase_y/times_to_zoom));
}

function realign_divs(old_x1, amount_to_increase_x,old_y1, amount_to_increase_y){

  var query_string = "book=" + document.getElementById('select_book').value + "&file_name=" + document.getElementById('select_scripture').value + "&old_y1="+ old_y1 + "&amount_to_increase_y=" + amount_to_increase_y; 
  var url = "realign.pl";
  xmlhttpPost(url,query_string);
  for(i=1;i<=199;i++){
    temp_div = parent.side_bar.transcription.document.getElementById(i);
    x1_loop = parseInt(temp_div.getAttribute('x1'));
    x1_mod = parseInt(x1_loop)+ parseInt(amount_to_increase_x);

    y1_loop = parseInt(temp_div.getAttribute('y1'));
    y1_mod = parseInt(y1_loop)+ parseInt(amount_to_increase_y);

    if(x1_loop>= parseInt(old_x1)){
      temp_div.setAttribute('x1',x1_mod);
    }			

    if(y1_loop>= parseInt(old_y1)){
      temp_div.setAttribute('y1',y1_mod);
    }			
  }
}

  </script>



</head>

<body onLoad="if(!BrowserDetect.browser.match(/Chrome/)){}; do_initial_stuff();" >

<div id="browser_message"></div>
<div id="div_realign_number" name="div_realign_number" style="display:none"></div>
<div id="display_times_to_zoom" name="display_times_to_zoom" style="display:none;"></div>
<div id="original_font_size" name="original_font_size" style="display:none;"></div>
<div id="auto_expanded_font_size" style="display:none;" name="auto_expanded_font_size"></div>
<button id="btn_eliminate_line_breaks" onClick = "eliminate_line_breaks();" style="display:none;"></button>
<button id="btn_display_image" name = "btn_display_image" style="display:none;" onClick="window.frames['iframe_scripture'].document.getElementById('pic').src = 'images_expanded/' + document.getElementById('select_scripture').value;"></button>
<div id="text_space_length" style="display:none;"></div>
<div id="top_panel" name="top_panel">

Book: <select id = "select_book" onchange="htmlData('get_pages.pl', 'book='+this.value)" >  
<option>Please choose a book</option>

END

opendir(DIR,"books");

for(sort { $a cmp $b }(readdir(DIR))){
	next if $_=~/^\./;
	print qq(<option>$_</option>);
}

print <<END;

</select>
<br>

<div id="div_pages" name="pages"></div>

Line#:
<input type = "text" id = "line_number" name = "line_number" size="1" style="display:inline">
<button id="button_go_to_line" name="button_go_to_line" onClick="setTimeout('go_to_line();',1000);" style="display:inline;">go</button> <div id="last_page" name="last_page" style="display:inline;"></div>

</div>
<script>

function make_font_consistant(){
  var inverse = 1/(parseInt(document.getElementById('zoom_display').innerHTML.replace(/%/,""))*.01);
  document.getElementById('new_font_size').value=Math.round(parseInt(document.getElementById('font_size_display').innerHTML.replace(/px/,'')) * inverse);
  document.getElementById('btn_fix_xml').click();
}
</script>
<div id="mid_panel" name="mid_panel">
<table ><tr>
<td>font size: </td><td><div id="slider_font_size" style="width:200px;" onClick="\$('#slider_font_size').slider('value',(\$('#slider_font_size').slider('value')-1));"></div></td><td><div id="font_size_display" style="display:none"></div><input type="button" style="display:none;"  onClick="make_font_consistant();" value="set font for page" ><div id="zoom_display" style="display:none;"></div></td>
</tr><tr>
<td>letter spacing:&nbsp;</td><td><div id="slider_kern" style="width:200px;" onClick="\$('#slider_kern').slider('value',(\$('#slider_kern').slider('value')-1));"></div></td><td><div id="kern_display" style="display:inline"></div></td>
</tr></table>

<button id = "focus_text_space" name="focus_text_space" onClick = "javascript:document.getElementById('text_space').focus();" style="display:none;">return cursor</button>
<button id="btn_line_up"   name="btn_line_up"    onClick="send_text(1);if(2<=parseInt(document.getElementById('line_number').value)){document.getElementById('line_number').value--;go_to_line();}" style="display:inline;">Save + Line up</button>
<button id="btn_line_down" name="btn_line_down"  onClick="send_text(1);if(parseInt(parent.side_bar.transcription.document.getElementById('total_lines').innerHTML)>parseInt(document.getElementById('line_number').value)){document.getElementById('line_number').value++;go_to_line();}" style="display:inline;">Save + Line down</button>
<button id="btn_next_asterisk" name="btn_next_asterisk" onClick="send_text(1);go_to_next_asterisk();">Save + next *</button>

<button onClick="alert(\$('#text_space').html() + ' ' + document.getElementById('text_space').innerHTML.length);" style="display:none;">show contents</button>
</div>
<button id ="reset_page" name="reset_page" onClick="click_reset_page();" style="display:inline;">reset page</button>
<button id ="cancel_reset_page" name="cancel_reset_page" onClick="click_cancel_reset();" style="display:none;">cancel</button>


<script>

function next_page(t){
	document.getElementById('select_scripture').selectedIndex++;
do_image_change_stuff();
}

function go_to_next_asterisk(){
	var flag=0;
	var start_num = parseInt(document.getElementById('line_number').value);
	if(start_num){start_num++;}
	start_num = start_num || 1;
	for(i=start_num; i<=199; i++){
		if (parent.side_bar.transcription.document.getElementById(i).innerHTML.match(/\\*/)){
			document.getElementById('line_number').value = i;
			go_to_line();
			flag++;
			break;
		}
	}
	if(flag==0){
		for(i=1; i<=start_num; i++){
			if (parent.side_bar.transcription.document.getElementById(i).innerHTML.match(/\\*/)){
				document.getElementById('line_number').value = i;ge
				go_to_line();
				flag=1;
				break;
			}
		}
	}
if(flag==0){
	alert('Finished looking for asterisks');

	}
}

</script>
 <input id="btn_ajax" name="btn_ajax" value="Go" type="button" onclick="xmlhttpPost('update_xml.pl');" style="display:none;">

<div id="xml_panel" name="xml_panel" style="display:none;">




<button id ="btn_fix_xml" name="btn_fix_xml" onClick="click_fix_xml();" style="display:inline;">fix xml</button>
<br>

<input type="hidden" id="realign_x" name="realign_x">
<input type="hidden" id="realign_y" name="realign_y">
<input type="hidden" id="realign_row" name="realign_row">

common row height: <div id="common_row_height" name="common_row_height" size="4" style="display:inline;"></div><br>

View width: <input type="text" id="view_width" name="view_width" size="4">
<br>


<table><tr>
<td><button id ="set_first_point" name="set_first_point" onClick="set_point('first');" style="display:inline;">col 1 a</button></td><td> <input type="text" id="Mouse1X" name="Mouse1X" value="0" size="4">
 <input type="text" id="Mouse1Y" name="Mouse1Y" value="0" size="4"></td>
</tr><tr>
<td><button id ="set_second_point" name="set_second_point" onClick="set_point('second');" style="display:inline;">col 1 b</button></td><td> <input type="text" id="Mouse2X" name="Mouse2X" value="0" size="4">
 <input type="text" id="Mouse2Y" name="Mouse2Y" value="0" size="4"></td>
</tr></table>

END

for($i=2;$i<20;$i++){
	print qq(<div><button id="btn_x_$i" name="btn_x_$i" onClick="set_point($i);" style="display:inline;">col $i</button><input type="text" id="x_$i" name="x_$i" size="4"><input type="text" id="y_$i" name="y_$i" size="4"></div>)
}

print <<END;

<button id="btn_row_top" name="btn_row_top" onClick="set_point('top');">row top</button>
<input type="text" id="row_top" name="row_top" size="4">
<br>
<button id="btn_row_bottom" name="btn_row_bottom" onClick="set_point('bottom');">row bottom</button>
<input type="text" id="row_bottom" name="row_bottom" size="4">
<br>
<table border="0"><tr>
<td><div style="display:none">baseline font size</div></td><td><div style="display:none"><input type="text" id="new_font_size" name="new_font_size" size="4"></div></td>
</tr><tr>
<td>letter position</td><td><input type="text" id="new_line_height" name="new_line_height" size="4"></td>
</tr><tr>
<td>letter spacing</td><td><input type="text" id="new_kern" name="new_kern" size="4"></td>
</tr></table>

<!--
<button id ="set_third_point" name="set_third_point" onClick="set_point('third');" style="display:inline;">third</button></td><td cols=2> <input type="text" id="col_x_second" name="col_x_second" value="0" size="4">
<button id ="set_fourth_point" name="set_fourth_point" onClick="set_point('fourth');" style="display:inline;">fourth</button> <input type="text" id="col_x_third" name="col_x_third" value="0" size="4"><br>
--!>

</div>


<br>
 

<button id="btn_focus" name="btn_focus" onClick="return_cursor(document.getElementById('text_space').childNodes[0],1);" style="display:none;">focus</button>

<!--



--!>

<script> var my_escapes = new Array();</script>


<script> var myDiacritic = new Array();</script>
END


for(keys %escape){

if($_=~/(\\|\')/){ #\ and ' require escaping
	$escape_char="\\";	
	
}



 print qq(<script>my_escapes['$escape_char$_'] = "$escape{$_}"; </script>\n);


}

for(keys %diacritic){



 print qq(<script>myDiacritic["$_"] = "1"; </script>\n);


}



print <<END;


<!--

<button onClick="alert(document.getElementById('text_space').innerHTML);"> box innerHTML</button>
<button onClick="alert(document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop);">scroll top</button>
<button onClick="alert(parent.side_bar.scripture_small.document.body.scrollTop);">scroll top</button>

<button onClick="alert(document.getElementById('iframe_scripture').contentWindow.document.body.scrollHeight);">scroll height</button>
<button onClick="alert(window.frames['iframe_scripture'].document.getElementById('pic').height);">image height</button>
<button onClick="alert(window.frames['iframe_scripture'].document.getElementById('pic').height + '  sc: ' + document.getElementById('iframe_scripture').contentWindow.document.body.scrollHeight);">all</button>
--!>


<table border="0" width="90%">
<tr valign="top">
<td>
	<div id = "scroll_position_v" name = "scroll_position_v" style="display:none;"></div><div id = "scroll_position_h" name = "scroll_position_h" style="display:none;"></div>


    <div id = "should_scroll" style="display:none;">yes</div>
    <b><div id = "line_number_display" style="display:none;">1</div></b>
	<div id="scroll_top_on_zoom_down" name="scroll_top_on_zoom_down" style="display:none;"></div>
	<div id="zoom_on_down" name="zoom_on_down" style="display:none;"></div>
	
	<div id="original_expansion_height" name="original_expansion_height" style="display:none;"></div> 
	
	<div id="current_rotation"></div>
	
	<div id="first_height" style="display:none;"></div>
	<div id="first_width" style="display:none;"></div>
	<div id="expanded_height" style="display:none;"></div>
	



</td>
</tr></table>

<script>
function check_diff_slider(slider_name,value){
	if (slider_name=="zoom"){
	
		if(\$('#zoom_on_down').html()==(\$('#slider_zoom').slider('value')-1)){
		\$('#slider_zoom').slider('value',\$('#zoom_on_down').html() );	
		document.getElementById('zoom_display').innerHTML = document.getElementById('zoom_on_down').innerHTML;
document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop =	document.getElementById('scroll_top_on_zoom_down').innerHTML;

		}
	}
}

function record_zoom_factors(){
	document.getElementById('scroll_top_on_zoom_down').innerHTML= document.getElementById('iframe_scripture').contentWindow.document.body.scrollTop;
	document.getElementById('zoom_on_down').innerHTML= \$('#slider_zoom').slider('value');

}

function return_percent(first, second){
	return parseInt((parseInt(first)/parseInt(second)*100));
}

<\/script>

<div  style="position:absolute;top:10px;left:400px;display:inline;">
<table style = "display:none;" border = "0" width="100%"><tr>

<td>font size: </td><td><div id="slider_font_size" style="width:200px;" onClick="\$('#slider_font_size').slider('value',(\$('#slider_font_size').slider('value')-1));"></div></td><td><div id="font_size_display" style="display:inline"></div></td>
<td>Combination resize: </td><td><div id="slider_font_special" onClick="\$('#slider_font_special').slider('value',(\$('#slider_font_special').slider('value')-1));" style="width:200px;"></div></td><td width="30"><div id="font_special_display" style="display:inline"></div></td>
</tr><tr>
<td>Line depth: </td><td><div id="slider_height" style="width:200px;" onClick="\$('#slider_height').slider('value',(\$('#slider_height').slider('value')-1));"></div></td><td><div id="input_box_display" style="display:inline"></div></td>
<td>letter spacing:&nbsp;</td><td><div id="slider_kern" style="width:200px;" onClick="\$('#slider_kern').slider('value',(\$('#slider_kern').slider('value')-1));"></div></td><td><div id="kern_display" style="display:inline"></div></td>
</tr><tr height="50px">
<td>Letter position: </td><td><div id="slider_line_height" style="width:200px;" onClick="\$('#slider_line_height').slider('value',(\$('#slider_line_height').slider('value')-1));"></div></td><td width="50"><div id="line_height_display" style="display:inline"></div></td>
<td>zoom:</td><td>
<div id="slider_zoom" style="width:200px;"  onmousedown="do_slider_zoom_onmousedown_stuff();record_zoom_factors();" onClick="check_diff_slider('zoom',\$('#slider_zoom').slider('value'));">


</td><td width="20px" height="20px" style="display:inline;">


<div id="scroll_top_display"           style="display:none;"></div>
<div id="scroll_height_display"        style="display:none;"></div>
<div id="current_scroll_top"           style="display:none;"></div>
<div id="current_scroll_height"        style="display:none;"></div>
<div id="current_scroll_percent"       style="display:none;">100</div>
<div id="current_scroll_width_percent" style="display:none;"></div>

</td></tr><tr>

<td colspan="6">

<button title="input line preset" onClick="set_font_slider_options('roman');">Roman</button>
<button title="input line preset" onClick="set_font_slider_options('ipa');">IPA</button>
<button title="input line preset" onClick="set_font_slider_options('sea');">SEA</button>

</td>


</tr></table>
</div>


<!--
<table border="0" style="display:inline">
	<tr>
		<td>line height</td><td>letter spacing</td><td>box height</td><td></td>
	</tr>
	<tr>
	<td>
<button onClick="line_height_decrease();" style="display:inline;"> < </button>
<button onClick="line_height_increase();" style="display:inline;"> > </button>
</td><td>
<button onClick="kern_decrease();" style="display:inline;"> < </button>
<button onClick="kern_increase();" style="display:inline;"> > </button>
</td><td>
<button onClick="box_height_decrease();" style="display:inline;"> < </button>
<button onClick="box_height_increase();" style="display:inline;"> > </button>
</td>
<td>

	 	</td>
</tr></table>

--!>

	<div id = "input_box_position_top" name = "input_box_position_top"></div>

 
  
  <div id="result"></div>
  <div id="exc"></div>



<div id = "font_name_display" name = "font_name_display" size="1" style="display:inline"></div>    
<!--

<button onclick="doFormat('bold'); "><strong>B</strong></button> 
<button onclick="doFormat('italic');"><em>I</em></button> 
<button onclick="doFormat('underline');"><span style="text-decoration:underline">U</span></button> 
<button onclick="doFormat('SubScript');"><em>Sub</em></button> 
<button onclick="doFormat('SuperScript');"><em>Su</em></button> 


--!>
<!--
<select id = "select_font" name = "select_font" onchange="document.execCommand('FontName',0,this.options[this.selectedIndex].text);prepare_set_font();document.getElementById('font_name_display').innerHTML=this.value;">
-->

<select id = "select_font" name = "select_font" style="display:inline;"onChange="document.execCommand('FontName',0,this.options[this.selectedIndex].text);prepare_set_font();document.getElementById('font_name_display').innerHTML=this.value;">
<option selected>Font</option>
<option value="Charis Sil">Charis Sil</option>
<option value="Doulos Sil">Doulos Sil</option>
<option value="Arial unicode MS">Arial unicode MS</option>
<option value="System">System</option>
<option value="Arial">Arial</option>
<option value="Fixedsys">Fixedsys</option>
<option value="MS Sans Serif">MS Sans Serif</option>
<option value="Arial">Arial</option>
<option value="Arial Black">Arial Black</option>
<option value="Courier New">Courier New</option>
<option value="Georgia">Georgia</option>
<option value="Impact">Impact</option>
<option value="Lucida Console">Lucida Console</option>
<option value="Lucida Sans Unicode">Lucida Sans Unicode</option>

<option value="Tahoma">Tahoma</option>
<option value="Times New Roman">Times New Roman</option>
<option value="Verdana">Verdana</option></select>

<button id = "button_set_font" name = "button_set_font" onClick="document.execCommand('FontName',null,document.getElementById('select_font').value);" style="display:none;">set font</button>

<table><tr><td>
<div id="call_status" name="call_status" style="display:none;"></div>
</td>
<td>     <input type="button" class="inputSubmit" value="<-Rotate" name="RotateL" id="RotateL" style="display:none;" onclick="\$('#iframe_scripture').contents().find('#pic').rotateLeft(1);">
</td><td><input type="button" class="inputSubmit" value="Rotate->" name="RotateR" id="RotateR" style="display:none;" onclick="\$('#iframe_scripture').contents().find('#pic').rotateRight(1);">
</td>


<td> <div id = "rotation" name = "rotation"></div></td>

</tr></table>

<!--
<button onClick="second_part_length=get_selection();" style="display:inline;">insert selection</button>
--!>


<div id="trim"></div>

<div id = "image_width" style = "display:none;" >width</div>
<div id = "image_height" style = "display:none;">height</div>
<div id = "div_scripture" name = "iframe_scripture"  style = "position:absolute;top:250px;width:100%;height:350px;" >
  <iframe MARGINWIDTH ="0" MARGINHEIGHT= "0" id = "iframe_scripture" name = "iframe_scripture" style="position:absolute;" width = "98%" height = "400px" src="scripture.html"  ></iframe>
  <div id = "text_space"  onmouseup="" onmousedown="window.getSelection().removeAllRanges();" onkeydown = "do_key_down_stuff(event);"  onkeyup="do_key_up_stuff(event);check_character();" contentEditable="true" style="height:20px;line-height:20px;letter-spacing:0px;font-size:20px;width:97%;position:absolute;top:200px;left:2px;background-color:yellow;"></div>
  <div id="panel_char_buttons" name = "panel_char_buttons" style="position:absolute;top:450px;width:90%;">
<div style="float:left;">
  <button id ="btn_next_page_2" name="btn_next_page2" onClick="next_page();" style="display:inline;">Next page</button>
<button id="btn_undo_line" name="btn_undo_line" onClick="document.getElementById('button_go_to_line').click();">Undo line</button>
<button onClick="send_text(1);go_to_next_asterisk();">Save + next *</button>
</div>

<div style="float:right;">
<button id ="btn_realign" name="btn_realign" onClick="realign();" style="display:inline;">realign</button>
<script>
function toggle_buttons(){
	if (document.getElementById('button_div').style.display.match(/inline/)){
		document.getElementById('button_div').style.display="none";
		document.getElementById('generic_button_div').style.display="inline";
		document.getElementById('btn_toggle_buttons').value="less buttons";
	}else{
		document.getElementById('button_div').style.display="inline";
		document.getElementById('generic_button_div').style.display="none";
		document.getElementById('btn_toggle_buttons').value="more buttons";
	}
}

</script>

<input type="button" id="btn_toggle_buttons" name="btn_toggle_buttons" onClick="toggle_buttons();" value="more buttons">
</div>
<br>
<div class="button" id="button_div" name="button_div" style="display:inline" >
</div>


<div class="button" id="generic_button_div" name="generic_button_div" style="display:none">

END

for(@characters){ #create button panel
  next if $_=~/^\./;
  $_=~s/\n//;
  $character = $_;
	if($character!~/\W/){
  	print qq(&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;);
  	next;
	}
	$character=~s/\s//g;
	$l=length($character);
  print qq(<input class="button" type="button" id="some_button"  name="some_button" onClick = "check_character('$character');" title="$reverse_escape{$_}"  value="$_">);
}

print <<END;



</div>

<br>
<div id="slider_button_size" style="width:200px;" onClick="\$('#slider_button_size').slider('value',(\$('#slider_button_size').slider('value')));"></div>
</div>
<form id="form_transcription" name="form_transcription">
			<input type = hidden id = "file_name" name = "file_name" />
			<input type = hidden id = "text_line" name = "text_line" />
			<input type = hidden id = "x1" name = "x1" />
			<input type = hidden id = "y1" name = "y1" />
			<input type = hidden id = "x2" name = "x2" />
			<input type = hidden id = "y2" name = "y2" />
			<input type = hidden id = "image_width" name = "image_width" />
			<input type = hidden id = "image_width_px" name = "image_width_px" />
			<input type = hidden id = "image_height_px" name = "image_height_px" />
			<input type = hidden id = "line_height" name = "line_height" />			
			<input type = hidden id = "font_size" name = "font_size" />
			<input type = hidden id = "kern" name = "kern" />
			<input type = hidden id = "rotation"   name = "rotation" />
			<input type = hidden id = "box_height" name = "box_height" />
			<input type = hidden id = "num" name = "num" />
			<input type = hidden id = "book" name = "book" />
			<input type = hidden id = "text_align" name = "text_align" />
			<input type = hidden id = "col" name = "col" />
			<input type = hidden id = "row" name = "row" />


			</form>
</div>

</body>
</html>

END
