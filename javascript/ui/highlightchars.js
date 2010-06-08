$(function() {

    var theText = $("#theText");
    
    var theString = theText.text();

    var numCharacters = theString.length;
    
    var newHTML = "";
    
    for (i = 0; i <= numCharacters; i++) {
        
        var newHTML = newHTML + "<span>" + theString[i] + "</span>";
    
    }
    alert(newHTML);
    theText.html(newHTML);
    
    $("span").click(function(){
    
        $("span").removeClass("selected");
    
        $(this).addClass("selected");
        
        var nextSpan = $(this);

        for (i = 1; i <= 16; i++) {
  
            nextSpan = nextSpan.next();
        
            nextSpan.addClass("selected");
                        
        }
        
        $("#result").data("result", "");
                
        $(".selected").each(function() {
        
            var oldResults = $("#result").data("result");
                    
            var newResults = oldResults + $(this).text();
            
            $("#result").data("result", newResults);
        
        });
        
        $("#result").val($("#result").data("result"));
    
    });
    
    $("#sendit").click(function() {
    
        var toURL = "?=" + $("#result").val();
    
        window.location = toURL;
        
        return false;
    
    });

});