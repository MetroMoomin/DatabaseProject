#Install neo4j and dependencies on mashine
echo 0 > started.txt
echo "Start of setup on container side"
sudo apt-get update
sudo apt-get install -y gnupg ca-certificates curl wget gzip python3 pip
wget -O - https://debian.neo4j.com/neotechnology.gpg.key | sudo apt-key add -
echo 'deb https://debian.neo4j.com stable latest' | sudo tee -a /etc/apt/sources.list.d/neo4j.list
sudo apt-get update
sudo apt-get install -y neo4j
echo "Dependencies on container installed"

#Checks if db.csv has be ported over
while true; 
do
    if [ -e "/db.csv" ]; 
    then
        echo "DB found"
        break
    else
    echo "Waitign for db from parent"
        sleep 1
    fi
done

#Prepare DB for import
echo "Starting to prepare db"
mv /db.csv /Scripts
cd /Scripts
python3 PrepareDB.py
echo "db prepared"

#Configure neo4j
sed -i 's/#server.default_listen_address=0.0.0.0/server.default_listen_address=0.0.0.0/' /etc/neo4j/neo4j.conf
sed -i 's/#dbms.security.auth_enabled=false/dbms.security.auth_enabled=false/' /etc/neo4j/neo4j.conf

#Import db
neo4j-admin database import full --overwrite-destination --verbose --nodes=Category=/Scripts/categories.csv --relationships=Parent=/Scripts/relationships.csv
neo4j start
cd ..
echo 1 > started.txt