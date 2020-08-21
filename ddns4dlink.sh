#!/bin/sh

#Any of these items can be entered manually if you prefer
GDomain=falk.dncrjim.com    #Domain name (with or without subdomain),
Username=4U0BCYYADpC1Q2ZW   #username from Google Domains control panel
Password=jgX9pY8MKPzx4l7w   #password from Google Domains control panel
Email=dncrjim@gmail.com     #Email where you would like messages sent

#Syntax of import ddns.sh -d [domain] -u [username] -p [password] -i [IP] -e [email]
#Domain, Username, and Password are requred.
#If not provided,

#Select when you would like to receive emails 0=no 1=yes
EmailonMatches=1  #Email if script finds that current IP and GDomain IP already match
EmailonSuccess=1  #Email if script tries to change IP and API says good
EmailonFailure=1  #Email if script tries to change IP and API says anything other than good


#If a new IP is not provided, Pull WAN IP from the network interface. Should work if appliance is directly connected or through router
NewIP=$(wget -qO - icanhazip.com)

#Current IP of Google Domain
GDIP=$(nslookup $GDomain | awk 'FNR ==5 {print$3}')

#If WAN IP and GDomain IP are the same, log, optionally send email, and exit
if [[ "$NewIP" == "$GDIP" ]]; then
        logger "GDomain DDNS: WAN IP ($NewIP) unchanged, not updated"
        if [[ $EmailonMatches == 1 ]]; then
          echo "DDNS for $GDomain was tested and is up to date at $NewIP" | mail -s "DDNS for $GDomain Update Unnecessary" "$Email"
        fi
else
        #If WAN IP and GDomain IP don't match, send request to Google API to update, save response as Response
        Response=$(wget -qO - "https://$Username:$Password@domains.google.com/nic/update?hostname=$GDomain&myip=$NewIP")
        #May need to add 2nd option here for systems which do not include wget

        #If response includes correct new IP with the 'good' response, log, optionally send email, exit.
        if [[ "$Response" == "good $NewIP" ]]; then
         logger "GDomain DDNS: DDNS updated from $GDIP to $NewIP"
         if [[ $EmailonSuccess == 1 ]]; then
          echo "DDNS for $GDomain succeessfully from $GDIP to $NewIP" | mail -s "DDNS for $GDomain Update Successful" "$Email"
        fi

         #If response does not include correct new IP with the 'good' response, log, optionally send email, and exit.
        else
         logger -s "GDomain DDNS: Error: $Response"
         if [[ $EmailonFailure == 1 ]]; then
           echo "DDNS for $GDomain failed to  update from $GDIP to $NewIP. Server Response was: $Response." | mail -s "DDNS for $GDomain Update ::ERROR::" "$Email"
         fi
        fi
fi
