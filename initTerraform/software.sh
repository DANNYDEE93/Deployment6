
#!bin/bash

sudo apt-get update

#installs ability to install, update, remove, and manage packages/ y for yes/ able to use apt for adding python dependencies
sudo apt install -y software-properties-common

#downloads updated versions of python 
sudo add-apt-repository -y ppa:deadsnakes/ppa

#install python version
sudo apt install -y python3.7

#install python virtual environment
sudo apt install -y python3.7-venv

#installs essential build tools
sudo apt install -y build-essential

#installs the MySQL client library files
sudo apt install -y libmysqlclient-dev

#installs Python 3.7 files for app development
sudo apt install -y python3.7-dev

#create virtual environment
python3.7 -m venv test

source test/bin/activate

git clone https://github.com/DANNYDEE93/Deployment6.git

cd Deployment6

#install Dependencies
pip install -r requirements.txt

pip install gunicorn

pip install mysqlclient

#start Application
python -m gunicorn app:app -b 0.0.0.0 -D

#upgrade installed packages
sudo apt upgrade


