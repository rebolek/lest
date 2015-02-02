/*!
 * Lest.js
 */


 function test() {
 	txt = xml();
 	alert(txt);
 }

 function xml() {
 	var reg = new XMLHttpRequest();
 	reg.open("GET","index.r3?action=ping",false);
	reg.send();
	res = reg.response; 
	return res;
 }