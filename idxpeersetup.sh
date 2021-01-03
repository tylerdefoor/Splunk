#!/bin/bash

#This script sets up the index peer in a single site,
#Connects the peer to the master and license servers, as well as opening port for forwarders
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
listenport=9997			#Forwarder listen port
replicport=9100			#Replication port
secret=correcthorsebatterystaple		#Secret for cluster - HAS TO BE SAME ON MASTER NODE

#Connect to license master
#/opt/splunk/bin/splunk edit licenser-localslave -master_uri https://$licenseserver:$licensesplunkd

#Connect to master node
/opt/splunk/bin/splunk edit cluster-config -mode peer -master_uri https://$masterserver:$mastersplunkd -secret $secret -replication_port $replicport

#Disable the web server as it is not needed
/opt/splunk/bin/splunk disable webserver

#Listen for forwarders
/opt/splunk/bin/splunk enable listen $listenport

#Restart splunk for changes to take effect
/opt/splunk/bin/splunk restart