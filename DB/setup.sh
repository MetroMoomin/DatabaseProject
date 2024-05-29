#!/bin/bash

absPath=$(pwd)

## Dependency install:
#cat $absPath/Misc/installing.txt
sudo apt-get update
sudo apt-get install -y ca-certificates curl wget gzip lxc sshpass ssh python3 pip python3.10-venv

#cat $absPath/Misc/installed.txt

## Creating and setting up the container
sudo lxc-stop neo4j
sudo lxc-destroy neo4j
sudo lxc-create -n neo4j -t download -- -d ubuntu -r jammy -a amd64
sudo lxc-start neo4j
sleep 10
contIP=$(sudo lxc-ls -f | awk 'NR==2 {print $5}')
sudo lxc-attach -n neo4j -- apt-get update
sudo lxc-attach -n neo4j -- apt-get install -y ssh
sudo lxc-attach -n neo4j -- sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo lxc-attach -n neo4j -- sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
echo -e  "neo4j\nneo4j" | sudo lxc-attach -n neo4j -- passwd
sudo lxc-attach -n neo4j -- systemctl restart ssh
echo Container ip:$contIP
sleep 10
sshpass -p "neo4j" scp -o StrictHostKeyChecking=no -r $absPath/Scripts root@$contIP:/
echo "Container prepared"
#sudo lxc-attach -n neo4j -- bash /Scripts/containerSideSetup.sh &
sudo lxc-attach neo4j -- nohup bash /Scripts/containerSideSetup.sh &

## Pulling the database off site:
rm -r TemporaryResources
mkdir TemporaryResources
cd TemporaryResources
wget "https://drive.usercontent.google.com/download?id=1WOgdyW50iiv2KSQn0JACfOOwmC_KBWbz&export=download&authuser=0&confirm=t&uuid=8b8fd2c8-8990-4604-be1f-c14a0e3467a2&at=APZUnTURu0lxqwuYszinJc1sfxES:171181155254" -O db.gz
gzip -dc db.gz > taxonomy_iw.csv
mv taxonomy_iw.csv db.csv
cd ..
echo "Database downloaded"

#Puting resources in container
sshpass -p "neo4j" scp -o StrictHostKeyChecking=no $absPath/TemporaryResources/db.csv root@$contIP:/
echo "Database pushed to container"

#Waiting for container to finnish setup
while true; 
do
    if sudo lxc-info -n neo4j | grep -q "RUNNING"; 
    then
        neo4j_status=$(sshpass -p "neo4j" ssh root@$contIP 'cat /started.txt')
        if echo "$neo4j_status" | grep -q "1"; 
        then
            echo "DB imported and neo4j ready"
            breakmkdir: cannot create directory ‘/home/cnc/bin/dbcli’: No such file or directory

    else
        echo "Container is not running."
    fi
    sshpass -p "neo4j" ssh root@$contIP 'cat /nohup.out'
    sleep 0.2
done

#Finnishing up
mkdir -p ~/bin/dbcli
cd ~/bin/dbcli
python3 -m venv "dbli_env"
source "dbli_env/bin/activate"
pip install neo4j
deactivate

cd $absPath
pref="#!"
top=$HOME/bin/dbcli/dbli_env/bin/python3
top=$(echo $pref$top)
echo "$top" > dbcli.py
cat dbcli_template.py >> dbcli.py
chmod +x dbcli.py
cp dbcli.py ~/bin/dbcli/dbcli

#Check if line exists and if not add (mainly for dev)
line='export PATH="~/bin/dbcli:$PATH"'
file=~/.bashrc
if ! grep -qF "$line" "$file"; then
    echo "$line" >> "$file"
else
    echo "Line already exists in $file"
fi

source ~/.bashrc

#dev
firefox  http://$contIP:7474

#Cleanup
cd $absPath
rm dbcli.py
rm -r TemporaryResources
dbcli