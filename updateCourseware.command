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

rsync -avx -e "ssh" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/repository/files/*' "/Library/WebServer/Documents/Classroom/engine/repository/files/"
rsync -avx -e "ssh" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/images/*' "/Library/WebServer/Documents/Classroom/engine/images/"
rsync -avx -e "ssh" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/_/*' "/Library/WebServer/Documents/Classroom/engine/_/"
rsync -avx -e "ssh" 'bwhite@apexwebtest.com:~/apexwebtest/Classroom/engine/css/*' "/Library/WebServer/Documents/Classroom/engine/css/"
rsync -avx -e "ssh" 'root@devbox2.apexinnovations.com:~/apexinnovations.com/Classroom/engine/Systemic.html' "/Library/WebServer/Documents/Classroom/engine/"

echo "Completed Successfully!"
exit 0