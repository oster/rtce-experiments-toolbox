#!/opt/local/bin/node

/**
 * This script pretty-prints a pad record from etherpad-lite.
 * The record must have been retrieved via etherpad-lite API (getText).
 */

var fs = require('fs');

if (process.argv.length != 3) {
	console.log("usage: pretty-pad.js pad-record.json");
	process.exit(1);
}

var jsonFileName = process.argv[2];

fs.readFile(jsonFileName, 'utf8', function (err, data) {
  if (err) throw err;

  var pad = JSON.parse(data);

  console.log(pad.data.text);
});

