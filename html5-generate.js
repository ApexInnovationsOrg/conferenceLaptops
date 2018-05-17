var fs = require("fs-extra");
var page = require('webpage').create();
console.log("Created webpage...\n");


phantom.onError = function(msg, trace) {
	var msgStack = ['PHANTOM ERROR: ' + msg];
	if (trace && trace.length) {
		msgStack.push('TRACE:');
		trace.forEach(function(t) {
			msgStack.push(' -> ' + (t.file || t.sourceURL) + ': ' + t.line + (t.function ? ' (in function ' + t.function+')' : ''));
		});
	}
	console.log(msgStack.join('\n'));
	phantom.exit(1);
};

page.onError = function(msg, trace) {
	var msgStack = ['PHANTOM ERROR: ' + msg];
	if (trace && trace.length) {
		msgStack.push('TRACE:');
		trace.forEach(function(t) {
			msgStack.push(' -> ' + (t.file || t.sourceURL) + ': ' + t.line + (t.function ? ' (in function ' + t.function+')' : ''));
		});
	}
	console.log(msgStack.join('\n'));
	phantom.exit(1);
};

function getHTMLForCourseID(courseID, callback) {
	console.log(courseID);
	if (courseID === undefined) {
		if (typeof callback === "function") {
			callback({
				message: "Course ID not provided."
			});
		}
	}

	console.log("Opening webpage");
	page.includeJs("http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js", function() {

		page.open("https://google.com", function(status) {
			console.log("Status: " + status);
			if (status === "success") {
				page.evaluate(function() {
					console.log("Evaluating webpage for course ");

					var pageContents = $(document).html();

					if (typeof callback === "function") callback(pageContents);
				});
			} else {
				if (typeof callback === "function") {
					callback({
						message: "Status was not success: " + status
					});
				}
			}
		});
	})
};

getHTMLForCourseID(84, function(response) {
	if (typeof response === "object") {
		console.error(response.message);
		phantom.exit(1);
	} else {
		console.log(response);
		phantom.exit();
	}
});
