#!/bin/bash

RATE_LIMIT_VALUE=$1
echo "RATE_LIMIT_VALUE - " $RATE_LIMIT_VALUE
RATE_LIMIT_COUNTER_KEY=$2
echo "RATE_LIMIT_COUNTER_KEY - " $RATE_LIMIT_COUNTER_KEY
RATE_RENEWAL_PERIOD=$3
echo "RATE_RENEWAL_PERIOD - "$RATE_RENEWAL_PERIOD
RATE_POLICY=$4
echo "RATE_POLICY - "$RATE_POLICY

#if [[ "$RATE_LIMIT_VALUE" == *ph ]]; then 
#	AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT=${RATE_LIMIT_VALUE%ph}; AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL=3600; 
#elif [[ "$RATE_LIMIT_VALUE" == *pm ]]; then 
#	AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT=${RATE_LIMIT_VALUE%pm}; AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL=60; 
#elif [[ "$RATE_LIMIT_VALUE" == *ps ]]; then 
#	AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT=${RATE_LIMIT_VALUE%ps}; AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL=1; 
#fi;


#if [[ -z "$AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT" || -z "$AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL" || -z "$RATE_LIMIT_VALUE" ]]; then

if [ "${RATE_POLICY}" == api ]; then

	if [[ -z "$RATE_RENEWAL_PERIOD"  || -z "$RATE_LIMIT_VALUE" ]]; then
		echo "Empty remove Rate Limit"
		sed -i 's/<rate-limit-by-key[^>]*\/>//g' update-policy.sh; 
	else 
		echo "Add Rate Limit"
		sed -i "s/AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT/${RATE_LIMIT_VALUE}/g" update-policy.sh; 
		sed -i "s/AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL/$RATE_RENEWAL_PERIOD/g" update-policy.sh; 
	fi;

	sed -i "s/AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT/${RATE_LIMIT_VALUE}/g" update-policy.sh;
	sed -i "s/AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL/$RATE_RENEWAL_PERIOD/g" update-policy.sh;



	if [[ "$RATE_LIMIT_COUNTER_KEY" == "user-identity" ]]; then
		sed -i "s/@RATE_LIMIT_COUNTER_KEY@/@(context.Request.Headers.GetValueOrDefault(\\\\\"Authorization\\\\\",\\\\\"\\\\\").AsJwt()?.Subject)/g" update-policy.sh;
	else
		sed -i "s/@RATE_LIMIT_COUNTER_KEY@/@(context.Request.IpAddress)/g" update-policy.sh;
	fi

	sed -i '/AZURE_API_TRAFFIC_PRODUCT/s/<rate-limit-by-key[^>]*\/>//g' update-policy.sh


else

	if [[ -z "$RATE_RENEWAL_PERIOD"  || -z "$RATE_LIMIT_VALUE" ]]; then
		echo "Empty remove Rate Limit"
		sed -i 's/<rate-limit-by-key[^>]*\/>//g' update-policy.sh; 
	else 
		echo "Add Rate Limit"
		sed -i "s/AZURE_API_TRAFFIC_PRODUCT_ARREST_LIMIT_COUNT/${RATE_LIMIT_VALUE}/g" update-policy.sh; 
		sed -i "s/AZURE_API_TRAFFIC_PRODUCT_ARREST_LIMIT_INTERVAL/$RATE_RENEWAL_PERIOD/g" update-policy.sh; 
	fi;

	sed -i "s/AZURE_API_TRAFFIC_PRODUCT_ARREST_LIMIT_COUNT/${RATE_LIMIT_VALUE}/g" update-policy.sh;
	sed -i "s/AZURE_API_TRAFFIC_PRODUCT_ARREST_LIMIT_INTERVAL/$RATE_RENEWAL_PERIOD/g" update-policy.sh;



	if [[ "$RATE_LIMIT_COUNTER_KEY" == "user-identity" ]]; then
		sed -i "s/@RATE_LIMIT_PRODUCT_COUNTER_KEY@/@(context.Request.Headers.GetValueOrDefault(\\\\\"Authorization\\\\\",\\\\\"\\\\\").AsJwt()?.Subject)/g" update-policy.sh;
	else
		sed -i "s/@RATE_LIMIT_PRODUCT_COUNTER_KEY@/@(context.Request.IpAddress)/g" update-policy.sh;
	fi

	sed -i '/AZURE_API_TRAFFIC_ARREST/s/<rate-limit-by-key[^>]*\/>//g' update-policy.sh

fi

exit 0;
