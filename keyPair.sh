 #!/bin/bash
if [ ! -d "~/.ssh"]; then
	echo "No keypair detected. Generating..."
	ssh-keygen -b 2048 -t rsa -q -N ""
	echo "keypair generated. Insert bwhite@apexwebtest.com password."
	cat ~/.ssh/id_rsa.pub | ssh bwhite@apexwebtest.com "mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"
fi