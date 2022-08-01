 #!/bin/bash

if which node > /dev/null
    then
        echo "node is installed, skipping..."
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
echo "Pulling HTML5 courseware..."

WEBSERVERROOT=/Library/WebServer/Documents
WEBSERVERENGINE=$WEBSERVERROOT/Classroom

if [ -d $WEBSERVERENGINE ] 
then
    git -C $WEBSERVERENGINE pull
else
    cd $WEBSERVERROOT && git clone website_Classroom:ApexInnovationsOrg/website_Classroom Classroom
fi
exit 0
rsync -avx -e "ssh" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/repository/files/*' $WEBSERVERENGINE/repository/files/
rsync -avx -e "ssh" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/_/*' $WEBSERVERENGINE/_/
rsync -avx -e "ssh" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/includes/*' $WEBSERVERENGINE/includes/
rsync -avx -e "ssh" 'bwhite@apexwebtest.com:~/apexwebtest/font/*' $WEBSERVERROOT/font/

cd $DESKTOP/conferenceLaptops
npm run html5-generate


HTMLs=courseHTML/*OFFLINE.html
for f in $HTMLs
do
  NOSUFFIX=${f%.html}
  NOPREFIX=${NOSUFFIX##*/}
  PRODNAME=${NOPREFIX%OFFLINE}
  sudo cp $f $WEBSERVERENGINE
  touch $DESKTOP"/$PRODNAME.webloc"
  echo '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>URL</key><string>http://localhost/Classroom/engine/'$PRODNAME'OFFLINE.html</string></dict></plist>' > $DESKTOP"/$PRODNAME.webloc"
done


echo "Completed HTML5 Courseware Successfully!"
exit 0
