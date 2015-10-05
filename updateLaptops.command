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
rsync -avx -e "ssh -p 999" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/repository/PAGE_*' "$REPOFOLDER"
rsync -avx -e "ssh -p 999" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/repository/Components' "$REPOFOLDER"
rsync -avx -e "ssh -p 999" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/images' "$REPOFOLDER"
echo "Compiling course XMLs"
#fire off the compileXML php script on apexwebtest
rm -f $OFFLINEFOLDER'*OFFLINE*'
for i in $(file $HOME'/Desktop/*' | grep 'cannot open' | cut -d : -f 1); do rm $i; done
ssh -p 999 bwhite@apexwebtest.com 'cd ~/apexwebtest/tasks/compileXML/ && php compileXML.php'
echo "Saving course XMLs"
rsync -avx -e "ssh -p 999" 'bwhite@apexwebtest.com:~/apexwebtest/tasks/compileXML/*.xml' "$OFFLINEFOLDER"
rsync -avx -e "ssh -p 999" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/OFFLINE.swf' "$OFFLINEFOLDER"
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

rsync -avx -e "ssh -p 999" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/Hemispheres2.0OFFLINE.swf' "$OFFLINEFOLDER"
rsync -avx -e "ssh -p 999" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/CanadianHemispheres2.0OFFLINE.swf' "$OFFLINEFOLDER"

echo "Completed Successfully!"
exit 0