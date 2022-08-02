What this does:

Updates the laptops with the current courseware on apexinnovations.com. The laptops are used for conferences to be presented where there is no wifi/limited internet. 

Assets:
The access keys and aws credentials are stored on the local network at apex hq under \\synology\development\conferenceLaptops\crednetials

You'll find the ssh keys to pull the github repos and the aws credentials to pull s3 files.

How it does:
1. Pull the website_Classroom repository and put it on to the local webserver
2. Run getCourses.js which fires up a puppeteer browser which pulls the HTML of the courseware
2a Pull the active courses from /conferenceLaptops/compile.php?key=<key>
2b. The key is the 'password' for the compile.php file.
2c. The key is used to prevent unauthorized access to the file.
2d. The contents of compile.php is controlled by what active licenses the APEXINNOVATIONS LMS has. Add an active license, it'll show up in the list.
3. With the JSON pulled from compile.php, it will then try launching all the courses.
4. Once the course is launched and everything is stable (with the use of a 30 second timeout... need to get on that), it'll pull the HTML of the current page
4a. There is a slight modification to use http: instead of https: because the files will be pulled locally. There is no localhost SSL certificate.
5. It'll then save the HTML to the courseHTML folder
6. Copy the .html files to the local webserver
7. Create .webloc files to the courses on the desktop
8. Pull assets from aws s3 to the local webserver


Prerequisites:
1. Install node.js / npm (to run the getCourses.js file)
2. Install aws cli (pull s3 assets. Normally served by cloudfront through ace-cdn.apexinnovations.com)
3. Install local webserver (apache2)
4. Add 'Header set Access-Control-Allow-Origin *' to the conf or .htaccess (to allow cross-origin requests to the assets)
5. Add 127.0.0.1 ace-cdn.apexinnovations.com to the hosts file (so the assets are pulled by the local webserver)

Gotchas:
1. Apple silicon is awesome. Just a bit early at the time of writing this in adoption. You have to run the terminal with Rosetta compatibility otherwise it'll throw a spawn error when running puppeteer or phantomJS
2. Python 2 is what is probably going to be installed by default with Mac OS devtools. You need Python 3.7 or higher to run aws cli. 
3. I left the html5-generate.js file in the repository. It reads pretty easily and JJjr's code lives on. However, phantomJS crashes if there are more than 2 courses to load. So I 'rewrote' it using puppetteer, which can handle a lot more courses (yay chrome)