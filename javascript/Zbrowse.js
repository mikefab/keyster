// ZNIPPets.com, "Zbrowse.js", by DocOzone... basic browser variables...

function makeZbrowse() { this.id = "Zbrowse";}

makeZbrowse.prototype.width = function() {return Zflag.IE?document.body.clientWidth:window.innerWidth;}
makeZbrowse.prototype.height = function() {return Zflag.IE?document.body.clientHeight:window.innerHeight;}
makeZbrowse.prototype.scrollY = function() {return Zflag.IE?document.body.scrollTop:pageYOffset;}
makeZbrowse.prototype.scrollX = function() {return Zflag.IE?document.body.scrollLeft:pageXOffset;}

Zbrowse = new makeZbrowse();