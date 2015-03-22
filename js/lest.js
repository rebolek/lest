/*!
 * Lest.js
 */


function test() {
 	reply = action("ping");
 	setContent("reply", reply);
}

function debug(data) {
	console.debug("DEBUG:" + data);
}

function getAttr(id, attr) {
	console.debug('Get in:' + id + '/' + attr);
	var elem = document.getElementById(id);
	return (elem[attr]);
}

function setAttr(id, attr, data) {
	var elem = document.getElementById(id);
	elem[attr] = data;
}


function action(act,data,target) {
	/* TODO: Add support for data */
	var reply = sendAction(act);
	setContent(target,reply);
}

function sendAction(act) {
 	var reg = new XMLHttpRequest();
 	act = 'index.r3?action=' + act;
 	reg.open('GET', act, false);
	reg.send();
	res = reg.response; 
	return res;
}

function setContent(id, data) {
	var elem = document.getElementById(id);
	elem.innerHTML = data;
}

// watcher

function watchFunc() {
//	alert("Interval reached");
	var reply = sendAction("ping","","");
	console.debug(reply);
}

// var watcher = setInterval(watchFunc, 5000);