
# crx-scrpt_dyndns_dual-wan

COREX MIKROTIK DynDNS update script for dual WAN, v1.0
 
### Features
 - check Mikrotik multi ISP's interfaces and update DynDNS records.
 - script is created to check mikrotik device with dual WAN interface and for router access on the backup interface but from main fqdn.
 - script is working on router OS 7.7 and above.
 - IP address update procedure is based on interface distance. 
 - Example to understand backend operation:
	:global IspDictionary ({"primary-ISP.getmyip.com"="digi"; \ 
						"backup-ISP.getmyip.com"="ether1"})

	Router can be accessed on primary-ISP.getmyip.com fqdn on the interface named "digi" as primary ISP.
	Router has a backup ISP on backup-ISP.getmyip.com fqdn on the interface named "ether1".
	In this case "digi" interface has lower distance then "ether1" interface.
	
	Script will check "digi" interface's ip address and will update primary-ISP.getmyip.com address in your DynDNS account.
	
	When "digi" interface is down, backup ISP's "ether1' interface will be active on the router.
	In this case the script will update my-primary.getmyip.com fqdn with "ether1" ip address, so your router can be accessed on the backup ISP's interface on the main fqdn.
	
	IMPORTANT!!!! 
	This script does not change any value in your router. 
	This script gets IP address information from router interfaces only and put them into dyndns account.
	Active and backup ISP changes must be solved from other source.
	

### Usage

<pre><code>
# USAGE:
# - edit crx-scrpt_dyndns_dual-wan.rsc file: ddnsuser and ddnspass for DynDNS connection
# 	edit IspDictionary dictionary, first key is the primary FQDN, first value is the primary ISP's interface name.
#   Second key and value are the backup ISP's details.
# - copy modified crx-scrpt_dyndns_dual-wan.rsc file on the MIKROTIK device.
# - Create task scheduler to trigger the script in every 5 minutes:
# 	/system scheduler add interval=00:05:00 name=COREX_DynDNS_update on-event="import crx-scrpt_dyndns_dual-wan.rsc"
# - For output check mikrotik log, Example output:
# 	Primary ISP: digi
# 	COREX-DNS:  primary-ISP.getmyip.com dont need changes
# 	COREX-DNS:  backup-ISP.getmyip.com dont need changes
#	...
#	Primary ISP: ether1-NET
#	COREX-DNS: Old IP address = 44.119.19.71
#	COREX-DNS: Fresh IP address = 192.168.30.118
#	COREX-DNS: Update IP needed, Sending UPDATE...!
#	COREX-DNS: primary-ISP.getmyip.com IP updated to 192.168.30.118!
#	...
#	COREX-DNS: Old IP address = 88.133.199.155
#	COREX-DNS: Fresh IP address = 192.168.31.109
#	COREX-DNS: Update IP needed, Sending UPDATE...!
#	COREX-DNS: backup-ISP.getmyip.com IP updated to 192.168.31.109!

</code></pre>



### Version

 - v1.0

### ToDo

 - waiting for bugs or feature requests (-:

## Changelog

 - [initial release] version 1.0

