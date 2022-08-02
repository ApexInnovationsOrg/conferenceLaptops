 #!/bin/bash

if which node > /dev/null
    then
        echo "node is installed, skipping..."
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && brew install node
    fi
echo "Pulling HTML5 courseware..."


echo "Cleaning environment"
if [ -d ./courseHTML ] ; then
    rm -r ./courseHTML
fi
mkdir ./courseHTML

rm ~/Desktop/*.webloc


DESKTOP=~/Desktop
WEBSERVERROOT=/Library/WebServer/Documents
WEBSERVERCLASSROOM=$WEBSERVERROOT/Classroom
WEBSERVERENGINE=$WEBSERVERCLASSROOM/Engine

if [ -d $WEBSERVERCLASSROOM ] 
then
    git -C $WEBSERVERCLASSROOM pull
else
    git clone website_Classroom:ApexInnovationsOrg/website_Classroom Classroom && sudo mv Classroom $WEBSERVERROOT
fi

if [ -d ./website_root ] 
then
    git -C ./website_root pull
else
    git clone website_root:ApexInnovationsOrg/website_root
    sudo mkdir -p $WEBSERVERROOT/grfx
    sudo mkdir -p $WEBSERVERROOT/css
fi

sudo cp -r ./website_root/grfx $WEBSERVERROOT
sudo cp -r ./website_root/css $WEBSERVERROOT

cd $DESKTOP/conferenceLaptops
npm install && npm run getCourses



HTMLs=courseHTML/*OFFLINE.html
for f in $HTMLs
do
  NOSUFFIX=${f%.html}
  NOPREFIX=${NOSUFFIX##*/}
  PRODNAME=${NOPREFIX% OFFLINE}
  URLENCODED=${NOPREFIX// /%20}
  sudo cp "$f" $WEBSERVERENGINE
  touch $DESKTOP"/$PRODNAME.webloc"
  echo '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>URL</key><string>http://localhost/Classroom/engine/'$URLENCODED'.html</string></dict></plist>' > $DESKTOP"/$PRODNAME.webloc"
done
echo "Downloaded all HTML Successfully!"

for f in $HTMLs
do
  NOSUFFIX=${f%.html}
  NOPREFIX=${NOSUFFIX##*/}
  PRODNAME=${NOPREFIX% OFFLINE}
  echo "Pulling assets from S3 for $PRODNAME"
  aws s3 sync "s3://apex-ace/$PRODNAME/" "$WEBSERVERROOT/$PRODNAME/"
done

aws s3 sync "s3://apex-ace/Hemispheres 2.0 - HTML/" "$WEBSERVERROOT/Hemispheres 2.0 - HTML/"
aws s3 sync "s3://apex-ace/Snapshots/" "$WEBSERVERROOT/Snapshots/"
aws s3 sync "s3://apex-ace/Sandbox/" "$WEBSERVERROOT/Sandbox/"

#aws s3 cp "s3://apex-ace" "$WEBSERVERROOT" --recursive --exclude "*/*"

echo "Pulled all assets Successfully!"
exit 0
