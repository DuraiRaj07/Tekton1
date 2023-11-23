CACHE_DURATION=$1

if [ $CACHE_DURATION != null ]; then
	OUTBOUND_POLICY_XML="<cache-store duration=\\\"$CACHE_DURATION\\\" />"
	echo $OUTBOUND_POLICY_XML
	export OUTBOUND_POLICY_XML

	CACHE_DURATION_POLICY=${OUTBOUND_POLICY_XML//\"/\\\"}
	sed -i "s#@CACHE_DURATION_OUTBOUND@#${CACHE_DURATION_POLICY//&/\\&}#g" update-policy.sh	


else
   echo "Please provide proper Integer value" 

fi
