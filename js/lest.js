/*!
 * Lest.js
 */

var lestWords = {};

function setWord(word, value) {
	lestWords[word] = value;
}

function getWord(word) {
	return lestWords[word];
}

function toParams(data) {
	console.debug(typeof data);
	var out = new Array();
	for (key in data) {
		console.debug(key, encodeURIComponent(data[key]));
	    out.push(key + '=' + encodeURIComponent(data[key]));
	}
	return out.join('&');
}

function send(act, data) {
 	var reg = new XMLHttpRequest();
 	var act = "index.r3?action=" + act;
 	reg.open("GET", act, false);
	reg.send(data);
	var res = reg.response; 
	return res;
}

function sendAction(act, data) {
 	console.debug("OACT");
 	console.debug("1ACT:" + act);
 	var reg = new XMLHttpRequest();
 	var act = "index.r3?action=" + act + "&" + toParams(data);
 	console.debug("ACT:" + act);
 	reg.open("GET", act, false);
	reg.send();
	var res = reg.response; 
	console.debug("RES:" + res);
	return res;
}

function setContent(id, data) {
	var elem = document.getElementById(id);
	elem.innerHTML = data;
}

function getAttr(id, attr) {
	var elem = document.getElementById(id);
	return (elem[attr]);
}

function setAttr(id, attr, data) {
	var elem = document.getElementById(id);
	console.debug("SET:" + elem.id + "/" + attr + "=" + data);
	elem[attr] = data;
}

// watcher

function watchFunc() {
//	alert("Interval reached");
	var reply = sendAction("ping","","");
	console.debug(reply);
}

// var watcher = setInterval(watchFunc, 5000);