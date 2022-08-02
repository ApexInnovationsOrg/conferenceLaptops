'use strict';

const puppeteer = require('puppeteer');
const fs = require('fs');

const writeCourseHTMLToFilesystem = async (course, callback) => {
    if (typeof course === undefined) {
		if (typeof callback === "function") {
			callback({
				message: "Course not provided."
			});
		}
	}

	try {
		var path = ("courseHTML/" + course.Name + " OFFLINE.html");
		await fs.writeFileSync(path, course.HTML, err =>{
            if(err){
                console.error(err);
            }
        });
		if (typeof callback === "function") callback();

	} catch (error) {
        console.error(error);
		if (typeof callback === "function") {
			callback({
				message: error.message
			});
		}
	}
}

const getHTMLForCourseID = async (courseID, callback) => {
    if (typeof courseID === undefined) {
        if (typeof callback === "function") {
            callback({
                message: "Course ID not provided."
            });
        }
    }

    try {
        const browser = await puppeteer.launch();
        const page = await browser.newPage();
        await page.goto("https://apexwebtest.com/scripts/aicc/aicc_relay.php?courseID=" + courseID + "&clientID=APEXINNOVATIONS&AICC_SID=466ce23&AICC_URL=https://www.apexwebtest.com");
            
            var coursePage = await page.evaluate(() => {
                return document.body.innerText;
            });

            if (coursePage.indexOf("END USER LICENSE AGREEMENT") > -1) {
                page.evaluate(() => {
                    // check if end user license agreement popped up
                    document.getElementById("passThrough").submit();
                });
            }


            var coursewareCheck = setInterval(async function() {

                var enginePage = await page.evaluate(() => {
                    return document.body.innerText;
                });


                    setTimeout(async ()=> {
                        // little bit extra wait even though the courseware claims it's ready
                        var pageContents = await page.evaluate(() =>{
                            return document.documentElement.outerHTML.replaceAll('https:', 'http:');
                        });

                        if (typeof callback === "function") callback(pageContents);
                        await browser.close();
                    }, 30000);
                
            }, 10000);



    } catch (error) {
        if (typeof callback === "function") {
            callback({
                message: error.message
            });
        }
    }
};  


(async()=>{
	// get courses
	console.log("Getting courses...");
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto("https://apexwebtest.com/conferenceLaptops/compile.php?CONFERENCE_LAPTOPS_KEY=eeyJrdW0ondatUC5cPWC");
    const courses = await page.evaluate(function() {
        return JSON.parse(document.body.innerText);
    });
    let coursesProcessed = 0;
    var dotString = "";
    var countingInterval = setInterval(function() {
        dotString += ".";
        console.log(dotString);
    }, 1000);
    for(let course of courses){
        console.log("Getting HTML for course " + course.ID + " - " + course.Name);

        getHTMLForCourseID(course.ID, function(response) {
            console.log("Successfully retrieved HTML for course " + course.ID + " - " + course.Name);
            course.HTML = response;
            coursesProcessed++;

            writeCourseHTMLToFilesystem(course, function() {
                if (coursesProcessed === courses.length) {
                    clearInterval(countingInterval);
                    console.log("Done!");
                    process.exit(0);
                }
            });
        });
    };
})();
