# GDomains_DDNS
Bash script to update ddns records on google domains.
Should work with full domains or subdomains
requires few/no additional packages, so it should work on very small installs
checks if the domain is already correct eliminating spam requests for updates which could cause a ban and allowing script to run frequently
designed to take inputs instead of using fixed variables so it can be used when redirecting multiple subdomains

* [ ] fix to import variables
* [ ] fix possible problem where it sends error email even when response from API is good
* [ ] set up so that some variables are optional
* [ ] set up that inputs are checked
* [ ] set up option for interface to be discovered dynamically
* [ ] update readme (hehe)
