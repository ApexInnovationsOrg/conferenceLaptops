 #!/bin/bash
if [ ! -f  $HOME'/.ssh/id_rsa.pub' ]; then
	echo "No keypair detected. Generating..."
	ssh-keygen -b 2048 -t rsa -q -N ""
	echo "Keypair generated. Insert bwhite@apexwebtest.com password."
	cat ~/.ssh/id_rsa.pub | ssh bwhite@apexwebtest.com "mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"
else
	echo "Keypair detected. Can automatically ssh into apexwebtest"
fi
echo "Syncing from apexwebtest.com"
REPOFOLDER=$HOME'/Desktop/courses/Offline/repository'
mkdir -p $REPOFOLDER
REPOFOLDERIMAGES=$HOME'/Desktop/courses/Offline/repository/images'
mkdir -p $REPOFOLDERIMAGES
OFFLINEFOLDER=$HOME'/Desktop/courses/Offline/'
mkdir -p $OFFLINEFOLDER
rsync -avx 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/repository/PAGE_*' "$REPOFOLDER"
rsync -avx 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/images/*' "$REPOFOLDERIMAGES"
echo "Compiling course XMLs"
ssh bwhite@apexwebtest.com 'cd ~/apexwebtest/tasks/compileXML/ && php compileXML.php'
echo "Saving course XMLs"
rsync -avx 'bwhite@apexwebtest.com:~/apexwebtest/tasks/compileXML/*.xml' "$OFFLINEFOLDER"
rsync -avx 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/OFFLINE.swf' "$OFFLINEFOLDER"
XMLs=$OFFLINEFOLDER'*.xml'
DESKTOP=$HOME'/Desktop'
BLANK=''
echo "Generating SWF Launches and shortcuts"
for f in $XMLs
do
  NOSUFFIX=${f%.xml}
  NOPREFIX=${NOSUFFIX##*/}
  $(cd $OFFLINEFOLDER && cp OFFLINE.swf $NOPREFIX.swf)
  # PRODNAME='cat //courseware/@productName' | xmllint --shell "$f" | grep -v ">" | cut -f 2 -d "=" | tr -d \"

  PRODNAME=${NOPREFIX%OFFLINE}
  # take action on each file. $f store current file name
  if [ ! -f  $DESKTOP"/$PRODNAME" ]; then
    echo $DESKTOP"/$PRODNAME"
    ln -s $OFFLINEFOLDER$NOPREFIX.swf $DESKTOP"/$PRODNAME"
  fi
done