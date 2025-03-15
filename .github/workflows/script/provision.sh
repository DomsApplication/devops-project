#!/bin/bash

echo "Connected successfully!...................."

echo "=============> Set non-interactive mode to prevent prompts."
export DEBIAN_FRONTEND=noninteractive

echo "=============> Killing any running apt processes"
sudo killall apt apt-get || true
sudo rm -rf /var/lib/apt/lists/lock /var/lib/dpkg/lock /var/lib/dpkg/lock-frontend

echo "=============> Updating package lists"
sudo apt-get update -yq

echo "=============> Upgrading packages (avoid SSH prompt issue)"
sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" upgrade -yq --allow-downgrades

echo "=============> Installing essential packages"
sudo apt-get install -yq gnupg curl git unzip
export DEBIAN_FRONTEND=noninteractive

echo "=============> Installing Node.js 20 & Latest npm"
sudo apt-get remove -y nodejs npm libnode-dev || true
sudo apt-get autoremove -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g npm@latest

echo "========================================"
echo -n "NodeJS version: "; node -v
echo -n "npm version: "; npm -v
echo "========================================"

echo "=============> Install pm2 for process management"
npm install -g pm2
echo pm2 id "sample"

echo "=============> To import the MongoDB public GPG key, run the following command:"
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor

echo "=============> Create the list file for Ubuntu 22.04"
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list


echo "=============> Update package lists again"
apt-get update -yq

echo "=============> Install MongoDB 8.2.0"
sudo apt-get install -yq mongodb-org=8.0.0 mongodb-org-database=8.0.0 mongodb-org-server=8.0.0 mongodb-mongosh mongodb-org-mongos=8.0.0 mongodb-org-tools=8.0.0

echo "=============> Prevent automatic updates of MongoDB packages"
echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-database hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-mongosh hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections

echo "=============> Start and enable MongoDB service"
sudo systemctl start mongod
sudo systemctl enable mongod

echo "=============> Check MongoDB service status"
sudo systemctl status mongod --no-pager
