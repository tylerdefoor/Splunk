#!/bin/bash

username=splunk

#Check to make sure we're root
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root'" 1>&2
   exit 1
fi

#Get Splunk
wget -O splunk-8.1.1-08187535c166-Linux-x86_64.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.1.1&product=splunk&filename=splunk-8.1.1-08187535c166-Linux-x86_64.tgz&wget=true'

#Add the splunk user (can change this to be called anything
useradd $username

#Untar the file to /opt
tar -xvzf splunk-8.1.1-08187535c166-Linux-x86_64.tgz -C /opt

#Set the SPLUNK_HOME environment variable
echo "export SPLUNK_HOME=/opt/splunk" > /etc/profile.d/splunk.sh
export SPLUNK_HOME=/opt/splunk

#Change the ownership of the splunk folder to the splunk user
chown -R $username:$username $SPLUNK_HOME

#Change the ulimits for $username running splunk to the recommended from splunk
echo -e '*\thard\tnofile\t64000' >> /etc/security/limits.conf
echo -e '*\thard\tnproc\t16000' >> /etc/security/limits.conf
echo -e '*\thard\tfsize\t-1' >> /etc/security/limits.conf

#Turn of Transparent Huge Pages
#If on RedHat, change to redhat_transparent_hugepage
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag

#Start splunk as splunk user. Change the password when possible.
su - $username -c '/opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd correcthorsebatterystaple1!'

#Enable bootstart as the user
/opt/splunk/bin/splunk enable boot-start -user $username

#Create a systemd service that disables THP on startup
echo -e '[Unit]' >> /etc/systemd/system/disable-thp.service
echo -e 'Description=Disable Transparent Huge Pages (THP)' >> /etc/systemd/system/disable-thp.service
echo -e '\n' >> /etc/systemd/system/disable-thp.service
echo -e '[Service]' >> /etc/systemd/system/disable-thp.service
echo -e 'Type=simple' >> /etc/systemd/system/disable-thp.service
echo -e 'ExecStart=/bin/sh -c "echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled && echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag"' >> /etc/systemd/system/disable-thp.service
echo -e '\n' >> /etc/systemd/system/disable-thp.service
echo -e '[Install]' >> /etc/systemd/system/disable-thp.service
echo -e 'WantedBy=multi-user.target' >> /etc/systemd/system/disable-thp.service

#Reload the daemon and enable the script at startup
systemctl daemon-reload
systemctl start disable-thp
systemctl enable disable-thp