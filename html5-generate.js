var fs = require("fs");
var webpage = require('webpage');
var outerPage = webpage.create();

console.log("Created webpage...");

phantom.onError = function(msg, trace) {
	var msgStack = ['PHANTOM ERROR: ' + msg];
	if (trace && trace.length) {
		msgStack.push('TRACE:');
		trace.forEach(function(t) {
			msgStack.push(' -> ' + (t.file || t.sourceURL) + ': ' + t.line + (t.function ? ' (in function ' + t.function+')' : ''));
		});
	}
	// console.log(msgStack.join('\n'));
	phantom.exit(1);
};

outerPage.onError = function(msg, trace) {
	var msgStack = ['PHANTOM ERROR: ' + msg];
	if (trace && trace.length) {
		msgStack.push('TRACE:');
		trace.forEach(function(t) {
			msgStack.push(' -> ' + (t.file || t.sourceURL) + ': ' + t.line + (t.function ? ' (in function ' + t.function+')' : ''));
		});
	}
	// console.log(msgStack.join('\n'));
	// phantom.exit(1);
};

function getHTMLForCourseID(courseID, callback) {
	if (courseID === undefined) {
		if (typeof callback === "function") {
			callback({
				message: "Course ID not provided."
			});
		}
	}

	var coursePage = webpage.create();
	coursePage.onError = function(msg, trace) {
		var msgStack = ['PHANTOM ERROR: ' + msg];
		if (trace && trace.length) {
			msgStack.push('TRACE:');
			trace.forEach(function(t) {
				msgStack.push(' -> ' + (t.file || t.sourceURL) + ': ' + t.line + (t.function ? ' (in function ' + t.function+')' : ''));
			});
		}
		// console.log(msgStack.join('\n'));
		// phantom.exit(1);
	};

	coursePage.open("https://apexwebtest.com/scripts/aicc/aicc_relay.php?courseID=" + courseID + "&clientID=APEXINNOVATIONS&AICC_SID=466ce23&AICC_URL=https://www.apexwebtest.com", function(status) {
		if (status === "success") {

			// need to wait due to redirects
			setTimeout(function() {

				if (coursePage.content.indexOf("END USER LICENSE AGREEMENT") > -1) {
					coursePage.evaluate(function() {
						// check if end user license agreement popped up
						document.getElementById("passThrough").submit();
					});
				}

				// another wait for page loading
				var coursewareCheck = setInterval(function() {
					if (coursePage.content.indexOf("engineContainer") > -1) {
						clearInterval(coursewareCheck);
						coursewareCheck = undefined;

						setTimeout(function() {
							// little bit extra wait even though the courseware claims it's ready

							var pageContents = coursePage.evaluate(function() {
								return document.documentElement.outerHTML.replaceAll('https:', 'http:');
							});
							
							if (typeof callback === "function") callback(pageContents);
						}, 5000);
					}
				}, 3000);
			}, 10000);

		} else {

			if (typeof callback === "function") {
				callback({
					message: "Status was not success: " + status
				});
			}
		}
	});
};

function writeCourseHTMLToFilesystem(course, callback) {
	if (typeof course === undefined) {
		if (typeof callback === "function") {
			callback({
				message: "Course not provided."
			});
		}
	}

	try {
		var path = ("courseHTML/" + course.Name + " OFFLINE.html");
		fs.write(path, course.HTML);
		if (typeof callback === "function") callback();

	} catch (error) {
		if (typeof callback === "function") {
			callback({
				message: error.message
			});
		}
	}
};

! function main() {

	// get courses
	console.log("Getting courses...");
	outerPage.open("https://apexwebtest.com/conferenceLaptops/compile.php?CONFERENCE_LAPTOPS_KEY=eeyJrdW0ondatUC5cPWC", "post", {}, function(status) {
		console.log("Status: " + status);
		if (status === "success") {

			var courses = outerPage.evaluate(function() {
				return JSON.parse(document.body.innerText);
			});
			var coursesProcessed = 0;

			console.log("There are " + courses.length + " courses to process...");

			var dotString = "";
			var countingInterval = setInterval(function() {
				dotString += ".";
				console.log(dotString);
			}, 1000);

			for (var courseIndex in courses) {
				! function(course) {

					console.log("Getting HTML for course " + course.ID + " - " + course.Name);

					getHTMLForCourseID(course.ID, function(response) {
						if (typeof response === "object") {
							console.error(response.message);
							phantom.exit(1);
							return;
						}

						console.log("Successfully retrieved HTML for course " + course.ID + " - " + course.Name);
						course.HTML = response;
						coursesProcessed++;

						writeCourseHTMLToFilesystem(course, function() {
							if (typeof response === "object") {
								console.error(response.message);
								phantom.exit(1);
								return;
							}

							if (coursesProcessed === courses.length) {
								clearInterval(countingInterval);
								console.log("All course HTML successfully written to filesystem!");
								phantom.exit();
							}
						});
					});
				}(courses[courseIndex]);
			}
		} else {
			console.error("Unable to retrieve courses.");
			phantom.exit(1);
		}
	});
}();
