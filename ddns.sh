#!/bin/bash

#Any of these items can be entered manually if you prefer
GDomain=    #Domain name (with or without subdomain),
Username=   #username from Google Domains control panel
Password=   #password from Google Domains control panel
IP=         #Use if you want to manually Set IP
Email=      #Email where you would like messages sent

#Syntax of import ddns.sh -d [domain] -u [username] -p [password] -i [IP] -e [email]
while getopts d:u:p:i:e: option
do
  case "${option}"
    in
    d) GDomain=${OPTARG};;
    u) Username=${OPTARG};;
    p) Password=${OPTARG};;
    i) IP=${OPTARG};;
    e) Email=${OPTARG};;
  esac
done

#Select when you would like to receive emails 0=no 1=yes
EmailonMatches=0  #Email if script finds that current IP and GDomain IP already match
EmailonSuccess=1  #Email if script tries to change IP and API says good
EmailonFailure=1  #Email if script tries to change IP and API says anything other than good

#Verify Required Data (Domain, Username Password)
if [[ -z "$GDomain" ]] && { echo "GDomain not provided"; exit 1; }
if [[ -z "$Username" ]] && { echo "Username not provided"; exit 1; }
if [[ -z "$GDomain" ]] && { echo "Password not provided"; exit 1; }

#Get Interface Name
Interface=$(ip route get 1.1.1.1 | grep -Po '(?<=dev\s)\w+' | cut -f1 -d ' ')

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
