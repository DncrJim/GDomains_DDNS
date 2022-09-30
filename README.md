# GDomains_DDNS
Bash script to update ddns records on google domains through the API. Designed to be called by a cron job.
Should work with full domains or subdomains
Designed to be as universal as possible, and to run on stripped down distros such as those in nas boxes.

First checks current IP against new IP so it only sends requests when the IP has changed, eliminating potential bans and allowing script to run frequently.
Designed so that variables can be passed to the script or included in the code depending on user preference.

Variables which can be set either within the code or with flags
-d <domain>  (required)
-u <username>  (required)
-p <password>  (required)
-i <new ip address>
-e <email>

If no ip address is provided, script will attempt to find the WAN ip through the default gateway. Should work either on the network appliance (router) or on a device connected to the router.

If no email is provided, script will still log messages, but will obviously not be able to email them.

Variables set via flags take priority over any variables inserted in the code.
The first three variables are required either through flag or insertion in script, and will throw an error if missing.


* [ ] verify inputs
  * [x] verify non null
  * [ ] verify correct syntax
* [x] set up option for interface to be discovered dynamically
* [x] reset variables for email to 0 if no email is provided
* [ ] update code so that when email is not provided, error in resolving IP emails are not sent
* [ ] update readme (hehe)
