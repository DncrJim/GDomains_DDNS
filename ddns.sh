#!/bin/bash

#Syntax of import ddns.sh [domain] [username] [password] [interface(optional)] [IP(optional)] [email(optional)]

#Domain name (with or without subdomain), username/password from Google Domains control panel
#Any of these items can also be entered manually if you prefer
GDomain=
Username=
Password=
Interface=
IP=
Email=

#Pull WAN IP from the network interface. Should work no matter if appliance is directly connected or through router
#Commented out line is separate option if first one breaks or you don't have awk on your system
WANIP=$(host myip.opendns.com resolver1.opendns.com | grep "myip.opendns.com has" | awk '{print $4}')
#WANIP=$(wget -qO - icanhazip.com)

#Current IP of Google Domain
GDIP=$(host $MyGDomain | awk '/has address/ { print $4 ; exit }')

#If WAN IP and GDomain IP are the same, log and exit
if [ "$WANIP" == "$GDIP" ]; then
        logger "GDomain DDNS: WAN IP ($WANIP) unchanged, not updated"
else
        #If WAN IP and GDomain IP don't match, send request to Google API to update, save response as Response
        Response=$(wget -qO - https://$Username:$Password@domains.google.com/nic/update?hostname=$GDomain&myip=$WANIP)
        #If response includes correct new IP with the 'good' response, log, send email, exit.
        if [ "$Response" == "good $WANIP" ]; then
         logger "GDomain DDNS: DDNS updated from $GDIP to $WANIP"
         echo "DDNS for $GDomain succeessfully from $GDIP to $WANIP" | mail -s "DDNS for $GDomain Update Successful" "$Email"
         #If response does not include correct new IP with the 'good' response, log, send email, exit.
        else
         logger -s "GDomain DDNS: Error: $Response"
         echo "DDNS for $GDomain failed to  update from $GDIP to $WANIP. Server Response was: $Response." | mail -s "DDNS for $GDomain Update ::ERROR::" "$Email"
        fi
fi
