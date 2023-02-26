# COREX MIKROTIK DynDNS update script for dual WAN
# VERSION 1.0 - BUILT ON 2023.02.26.
#
# for more information check GitHub:
# https://github.com/bgabika/mikrotik_dyndns_for_dual_wan
#
# Test it in test environment to stay safe and sensible before 
# using in production!
# For bugs and feature requests mailto bg@corex.bg
############################################################

:global IspDictionary ({"primary-ISP.getmyip.com"="digi"; \ 
						"backup-ISP.getmyip.com"="ether1"})
						
:global ddnsuser "my_dyndns_user"
:global ddnspass "my_dyndns_token"

:global DynDnsFqdnPriority
:global IspInterfacePriority
:foreach mykey,myvalue in=$IspDictionary do={ :set $DynDnsFqdnPriority ($DynDnsFqdnPriority, $mykey); :set $IspInterfacePriority ($IspInterfacePriority, $myvalue) }

:global IspDistances ({})


:foreach interface in=$IspInterfacePriority \ 
	do={ \
	:global distance [ip route get [find where dst-address=0.0.0.0/0 and vrf-interface=$interface] distance ];
	:set ($IspDistances->"$interface") $distance
	}


:local interfacefunction \ 
	do={ \
		:global ddnsuser;
		:global ddnspass;
		:global IspInterfacePriority;
		:global DynDnsFqdnPriority;
		:global IspInterface [:pick $IspInterfacePriority $interfaceindex]; \ 
		:global DynDnsFqdn [:pick $DynDnsFqdnPriority $fqdnindex]; \ 
		:global IspIpActive [:resolve $DynDnsFqdn]; \ 
		:global IspIpFresh [ /ip address get [/ip address find interface=$IspInterface ] address ]; \ 
		
		:if ([ :typeof $IspIpFresh ] = nil ) \ 
		do={
			:log warning ("COREX-DNS: No ip address on $IspInterface .")
			} \ 
		else={
			:for i from=( [:len $IspIpFresh] - 1) to=0 \ 
			do={ 
				:if ( [:pick $IspIpFresh $i] = "/") \ 
					do={ 
					:set IspIpFresh [:pick $IspIpFresh 0 $i];
					   } 
			   }
			}
		
		
		:if ($IspIpActive != $IspIpFresh) \ 
			do={
				:log warning ("COREX-DNS: Old IP address = $IspIpActive")
				:log warning ("COREX-DNS: Fresh IP address = $IspIpFresh")
				:log warning "COREX-DNS: Update IP needed, Sending UPDATE...!"
				:global str "/nic/update\?hostname=$DynDnsFqdn&myip=$IspIpFresh&wildcard=NOCHG&mx=NOCHG&backmx=NOCHG"
				/tool fetch address=members.dyndns.org src-path=$str mode=http user=$ddnsuser \
				password=$ddnspass dst-path=("/DynDNS.".$DynDnsFqdn)
				:delay 1
				:global str [/file find name="DynDNS.$DynDnsFqdn"];
				/file remove $str
				:global IspIpActive $IspIpFresh
				:log warning "COREX-DNS: $DynDnsFqdn IP updated to $IspIpFresh!"
			} \ 
			else={
				:log warning "COREX-DNS:  $DynDnsFqdn dont need changes";
				}
		
		}


if ([:pick $IspDistances 0] < [:pick $IspDistances 1]) \ 
	do={ \ 
		:log warning ("Primary ISP: ".[:pick $IspInterfacePriority 0])
		$interfacefunction interfaceindex=0 fqdnindex=0 \ 
		:delay 1
		$interfacefunction interfaceindex=1 fqdnindex=1 \ 
		 
		} \ 
	
	else={ \ 
		:log warning ("Primary ISP: ".[:pick $IspInterfacePriority 1])
		$interfacefunction interfaceindex=1 fqdnindex=0 \ 
		:delay 1
		$interfacefunction interfaceindex=0 fqdnindex=1 \ 
	
		}

