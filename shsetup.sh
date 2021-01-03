#!/bin/bash

#This script sets up a search head in a single site
#Connects the search head to the master and license servers
#This assumes splunk is already started
#This assumes the account already has a valid splunk session and does not need to provide username/pw
#This assumes that the license server and master node are already set up and ready for connection
#Run this as the splunk owner, no need to sudo
#This will restart splunk at the end for changes to take effect
#Remember to edit the servername and default-hostname before this to be unique from others in cluster

#Variables
masterserver=192.168.0.234 	#Cluster Manager IP
licenseserver=10.0.4.1 	#License Server IP
mastersplunkd=8089		#Master SplunkD port
licensesplunkd=8089		#License Server Splunkd port
secret=correcthorsebatterystaple		#Secret for cluster - HAS TO BE SAME ON MASTER NODE
clusterips=192.168.0.53:9997,192.168.0.115:9997	#The index cluster IPs

#Connect to license master
#/opt/splunk/bin/splunk edit licenser-localslave -master_uri https://$licenseserver:$licensesplunkd

#Connect to master node
/opt/splunk/bin/splunk edit cluster-config -mode searchhead -master_uri https://$masterserver:$mastersplunkd -secret $secret 

echo -e '[indexAndForward]' >> /opt/splunk/etc/system/local/outputs.conf
echo -e 'index = false' >> /opt/splunk/etc/system/local/outputs.conf
echo -e '\n' >> /opt/splunk/etc/system/local/outputs.conf
echo -e '[tcpout]' >> /opt/splunk/etc/system/local/outputs.conf
echo -e 'defaultGroup = idxcluster' >> /opt/splunk/etc/system/local/outputs.conf
echo -e 'forwardedindex.filter.disable = true' >> /opt/splunk/etc/system/local/outputs.conf
echo -e 'indexAndForward = false' >> /opt/splunk/etc/system/local/outputs.conf
echo -e '\n' >> /opt/splunk/etc/system/local/outputs.conf
echo -e '[tcpout:idxcluster]' >> /opt/splunk/etc/system/local/outputs.conf
echo -e 'server=192.168.0.53:9997,192.168.0.115:9997' >> /opt/splunk/etc/system/local/outputs.conf

#Restart splunk for changes to take effect
/opt/splunk/bin/splunk restart