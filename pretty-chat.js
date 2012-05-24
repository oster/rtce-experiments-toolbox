#!/opt/local/bin/node

/**
 * This script pretty-prints a chat record from etherpad-lite.
 * The record must have been retrieved via etherpad-lite API (getChat).
 */

var fs = require('fs');

if (process.argv.length != 3) {
	console.log("usage: pretty-chat.js chat-record.json");
	process.exit(1);
}

var jsonFileName = process.argv[2];
var users = new Object();
var usersCount = 0;

fs.readFile(jsonFileName, 'utf8', function (err, data) {
  if (err) throw err;

  var chat = JSON.parse(data);

  chat.data.forEach(function(item) {	
	var username = item.userName;
	var userid = item.userId;
	var time = new Date(item.time).toLocaleTimeString();
	var msg = item.text;
	
	if (username == null) {
	   username = generateSequentialUserName(userid);
	}
	
	console.log("["+time+"] "+username+":> "+msg);
  });

});

function generateSequentialUserName(uid) {
  var res = users[uid];
  if (! res) {
    res = "User"+(++usersCount);
    users[uid] = res;
  }
  return res;
};


