// ZNIPPets.com, "Zprime.js", by DocOzone... default basic setup...

window.onerror = function() { return false; }
window.defaultStatus ="";
// that sets the status bar to "" and disables error reporting.

function makeZflag() {
	this.NS = document.layers ? 1:0;
	this.IE = document.all ? 1:0;
	this.gecko = document.getElementById ? 1:0;
	this.mac = (navigator.appVersion.indexOf("Mac") > -1) ? 1:0;
	this.opera = (navigator.appName.indexOf("Opera") > -1) ? 1:0;
	}

Zflag = new makeZflag();

if (Zflag.NS) {
	layerstart = "document.";
	layerstyle = "";  }
if (Zflag.gecko){
	layerstart = "document.getElementById('";
	layerstyle = "').style"; }
if (Zflag.IE){
	layerstart = "document.all.";
	layerstyle = ".style"; }
	
	function getZbrowser() {
alert(navigator.appName + " - " + navigator.appVersion); }