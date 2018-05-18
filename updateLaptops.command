 #!/bin/bash
 #generate keypair if none exists
if [ ! -f  $HOME'/.ssh/id_rsa.pub' ]; then
	echo "No keypair detected. Generating..."
	ssh-keygen -b 2048 -t rsa -q -N ""
	echo "Keypair generated. Insert bwhite@apexwebtest.com password."
	cat ~/.ssh/id_rsa.pub | ssh bwhite@apexwebtest.com "mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"
else
	echo "Keypair detected. Can automatically ssh into apexwebtest"
fi
#grab updated files from AWT
echo "Syncing from apexwebtest.com"
REPOFOLDER=$HOME'/Desktop/courses/Offline/repository'
mkdir -p $REPOFOLDER
REPOFOLDERIMAGES=$HOME'/Desktop/courses/Offline/repository/images'
mkdir -p $REPOFOLDERIMAGES
OFFLINEFOLDER=$HOME'/Desktop/courses/Offline/'
mkdir -p $OFFLINEFOLDER
rsync -avx -e "ssh" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/repository/PAGE_*' "$REPOFOLDER"
rsync -avx -e "ssh" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/images/*' "$REPOFOLDERIMAGES"
echo "Compiling course XMLs"
#fire off the compileXML php script on apexwebtest
rm -f $OFFLINEFOLDER'*OFFLINE*'
for i in $(file $HOME'/Desktop/*' | grep 'cannot open' | cut -d : -f 1); do rm $i; done
ssh bwhite@apexwebtest.com 'cd ~/apexwebtest/tasks/compileXML/ && php compileXML.php'
echo "Saving course XMLs"
rsync -avx -e "ssh" 'bwhite@apexwebtest.com:~/apexwebtest/tasks/compileXML/*.xml' "$OFFLINEFOLDER"
rsync -avx -e "ssh" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/OFFLINE.swf' "$OFFLINEFOLDER"
XMLs=$OFFLINEFOLDER'*OFFLINE.xml'
DESKTOP=$HOME'/Desktop'
BLANK=''
#make the swf know where to point and make shortcuts for the products on the desktop
echo "Generating SWF Launches and shortcuts"
for f in $XMLs
do
  NOSUFFIX=${f%.xml}
  NOPREFIX=${NOSUFFIX##*/}
  cd $OFFLINEFOLDER && cp OFFLINE.swf $NOPREFIX.swf
  # PRODNAME='cat //courseware/@productName' | xmllint --shell "$f" | grep -v ">" | cut -f 2 -d "=" | tr -d \"
  PRODNAME=${NOPREFIX%OFFLINE}
  ln -s -f $OFFLINEFOLDER$NOPREFIX.swf $DESKTOP"/$PRODNAME"
done
#creating the hemispheres 2.0 and canadian hemispheres 2.0 swfs....
rsync -avx -e "ssh" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/TranswarpOffline.swf' "$OFFLINEFOLDER"
cp "$OFFLINEFOLDER"/TranswarpOffline.swf "$OFFLINEFOLDER"/Hemispheres2.0OFFLINE.swf
mv "$OFFLINEFOLDER"/TranswarpOffline.swf "$OFFLINEFOLDER"/CanadianHemispheres2.0OFFLINE.swf
echo "Completed Flash Courseware Successfully!"

if which node > /dev/null
    then
        echo "node is installed, skipping..."
    else
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        brew install node
    fi
echo "Pulling HTML5 courseware..."

WEBSERVERROOT=/Library/WebServer/Documents
WEBSERVERENGINE=$WEBSERVERROOT/Classroom/engine

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
