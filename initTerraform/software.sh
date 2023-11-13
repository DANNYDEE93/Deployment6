#!bin/bash

sudo apt-get update
#installs ability to install, update, remove, and manage packages/ y for yes/ able to use apt for adding python dependencies
sudo apt-get install -y software-properties-common
#downloads updated versions of python 
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get update
#install python version
sudo apt-get install -y python3.7
#install python virtual environment
sudo apt-get install -y python3.7-venv
#installs essential build tools
sudo apt-get install -y build-essential
#installs the MySQL client library files
sudo apt-get install -y libmysqlclient-dev
#installs Python 3.7 files for app development
sudo apt-get install -y python3.7-dev



#create python virtual environment
python3.7 -m venv test
source test/bin/activate
#clone repo
git clone https://github.com/DANNYDEE93/Deployment6.git
cd Deployment6
pip install pip --upgrade
#install Dependencies
pip install -r requirements.txt
pip install mysqlclient
pip install gunicorn
python database.py
python load_data.py
#start Application
python -m gunicorn app:app -b 0.0.0.0 -D
source test/bin/activate





