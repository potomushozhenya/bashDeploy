#!/bin/bash

source spatial.config
DB_NAME=$(echo "${DB_NAME,,}")
PGPASSWORD=$DB_PSWD
baseDir=$(pwd)
cd ~
echo $DB_HOST:$DB_PORT:*:$DB_USER:$DB_PSWD%> .pgpass
chmod 600 ~/.pgpass
cd $baseDir
cd ../data
dataDir=$(pwd)
cd $baseDir
sudo apt-get -y --allow-change-held-packages --allow-remove-essential update
sudo apt -y --allow-change-held-packages --allow-remove-essential install postgis postgresql-14-postgis-3
sudo apt -y --allow-change-held-packages --allow-remove-essential install osm2pgsql
fPath=$(sudo find /etc/postgresql -name 'pg_hba.conf')
sudo sed -i -e 's/md5/trust/g' $fPath
sudo sed -i -e 's/peer/trust/g' $fPath
sudo service postgresql restart
sleep 15s
sudo -u postgres psql -c "create database $DB_NAME;"
sudo -u postgres psql -d $DB_NAME -c "CREATE EXTENSION postgis;"
cd $dataDir
while IFS= read -r line; do
    line=$(echo "$line" | sed 's/\r$//')
    name=$(echo ${line} | awk -F'/' '{print $5}')
    name=$(echo ${name} | awk -F'-' '{print $1}')
    nameFile=$"$name.osm.pbf"
    sudo wget -O $nameFile $line
    osm2pgsql -U $DB_USER -p $name -l -d $DB_NAME $nameFile
done < ../src/links.config