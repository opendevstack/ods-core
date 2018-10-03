#!/bin/bash
# this script checks for env variable HTTP_PROXY and adds it to the java sys vars
# 
if [[ $HTTP_PROXY != "" ]]; then

	proxy=$(echo $HTTP_PROXY | sed -e "s|https://||g" | sed -e "s|http://||g")
	proxy_hostp=$(echo $proxy | cut -d "@" -f2)
	
	proxy_host=$(echo $proxy_hostp | cut -d ":" -f1)
	JAVA_OPTS="$JAVA_OPTS -dhttp.proxyHost=$proxy_host -dhttps.proxyHost=$proxy_host"
	
	proxy_port=$(echo $proxy_hostp | cut -d ":" -f2)
	JAVA_OPTS="$JAVA_OPTS -dhttp.proxyPort=$proxy_port -dhttps.proxyPort=$proxy_port"

	proxy_userp=$(echo $proxy | cut -d "@" -f1)
	if [[ $proxy_userp != $proxy_hostp ]]; 
	then
		proxy_user=$(echo $proxy_userp | cut -d ":" -f1)
		JAVA_OPTS="$JAVA_OPTS -dhttp.proxyUser=$proxy_user -dhttps.proxyUser=$proxy_user"
		proxy_pw=$(echo $proxy_userp | sed -e "s|$proxy_user:||g")
		JAVA_OPTS="$JAVA_OPTS -dhttp.proxyPassword=$proxyPassword -dhttps.proxyPassword=$proxyPassword"
 	fi
 	export JAVA_OPTS=$JAVA_OPTS;
fi

