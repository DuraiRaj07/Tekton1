export AZURE_SUBSCRIPTION_ID=ac4234ff-d0ab-4634-b3c6-6179a9607144
export AZURE_GROUP_NAME=coetg
export AZURE_API_SERVICE_NAME=COEAPIManagement
export CI_PROJECT_NAME=StockLevelChecker

export RATE_LIMIT_VALUE=5pm
export RATE_LIMIT_COUNTER_KEY=user-identity
#RATE_LIMIT_VALUE=

#IP_ADDRESS_TO_FORBID="192.168.0.100, 10.0.0.10-to-10.0.0.20, 172.16.0.5, 30.0.0.10-to-30.0.0.20"
export IP_ADDRESS_TO_ALLOW="192.168.1.50, 10.0.0.10-to-10.0.0.20, 172.16.0.20,30.0.0.10-to-30.0.0.20"
#IP_ADDRESS_TO_FORBID=
#IP_ADDRESS_TO_ALLOW=

export CORS_ALLOWED_ORIGINS="http://api.example.com, https://demo.sample.com"
#CORS_ALLOWED_ORIGINS=""
CORS_ALLOW_CREDENTIALS="true"
#CORS_ALLOW_CREDENTIALS="false"
CORS_ALLOWED_METHODS="GET, POST"
#CORS_ALLOWED_METHODS="ALL"
CORS_CACHE_PERIOD_MAX_SECONDS=200
#CORS_CACHE_PERIOD_MAX_SECONDS=""
CORS_ALLOWED_HEADERS="Header1, header2, header3,header4"
CORS_EXPOSE_HEADERS="EHeader1, Eheader2,Eheader3"
#CORS_EXPOSE_HEADERS=""

BACKEND_OAUTH_PROVIDER_URL="https://alm-app-registry.auth.us-east-1.amazoncognito.com/OAUTH2/token"
BACKEND_OAUTH_CLIENT_ID="2t7ri9otobvsbt9kcoau3eobol"
BACKEND_OAUTH_CLIENT_SECRET="n85iohdn3r61dbo1cu62e0ckvonu1ha3s86tbnp38luvvp2stam"
#BACKEND_OAUTH_PROVIDER_URL=
#BACKEND_OAUTH_CLIENT_ID=
#BACKEND_OAUTH_CLIENT_SECRET=

export CACHE_DURATION=300
#export ACCEPT_HEADERS="Accept,Authorization,Accept-Charset"



echo "Values are - " ${RATE_LIMIT_VALUE} ${RATE_LIMIT_COUNTER_KEY} ${IP_ADDRESS_TO_ALLOW} ${IP_ADDRESS_TO_FORBID} ${CORS_ALLOWED_ORIGINS} ${CORS_ALLOW_CREDENTIALS} ${CORS_ALLOWED_METHODS} ${CORS_CACHE_PERIOD_MAX_SECONDS} ${CORS_ALLOWED_HEADERS} ${CORS_EXPOSE_HEADERS} ${BACKEND_OAUTH_PROVIDER_URL} ${BACKEND_OAUTH_CLIENT_ID} ${BACKEND_OAUTH_CLIENT_SECRET}

#IP_ADDRESS_TO_FORBID=$(echo "$IP_ADDRESS_TO_FORBID" | tr -d '[:space:]')
#IP_ADDRESS_TO_ALLOW=$(echo "$IP_ADDRESS_TO_ALLOW" | tr -d '[:space:]')


#CORS_ALLOWED_ORIGINS=$(echo "$CORS_ALLOWED_ORIGINS" | tr -d '[:space:]')
#CORS_ALLOWED_METHODS=$(echo "$CORS_ALLOWED_METHODS" | tr -d '[:space:]')
#CORS_ALLOWED_HEADERS=$(echo "$CORS_ALLOWED_HEADERS" | tr -d '[:space:]')
#CORS_EXPOSE_HEADERS=$(echo "$CORS_EXPOSE_HEADERS" | tr -d '[:space:]')

#Deploy API in Azure APIM
AZURE_API_ID=$(az apim api import -g ${AZURE_GROUP_NAME} --api-id  ${CI_PROJECT_NAME} --display-name ${CI_PROJECT_NAME} --service-name ${AZURE_API_SERVICE_NAME} --path ${CI_PROJECT_NAME} --specification-path ./${CI_PROJECT_NAME}.yaml --specification-format OpenApi --subscription-required false | jq -r '.name')

#AZURE_API_ID="StockLevelChecker"
echo ${AZURE_API_ID}

if [[ -z "$AZURE_API_ID" ]]; then 
  echo "**********Import failed. Check above for reasons. Exiting as failure**********";
  exit 1;
else
  echo "**********Deployed API without policies**********";
fi

export AZURE_API_ID=${AZURE_API_ID}


echo "**********Evaluvating policies**********"

cp ./policy_template.sh ./update-policy.sh
#################################################################################

#CORS policy updates in template
#if [ -n "${CORS_ALLOWED_ORIGINS}" ] && [ "${CORS_ALLOWED_ORIGINS}" != null ]; then

#  if [ -z "$CORS_CACHE_PERIOD_MAX_SECONDS" ] || [ "${CORS_CACHE_PERIOD_MAX_SECONDS}" = null ]; then
 # CORS_CACHE_PERIOD_MAX_SECONDS="empty"
  #fi
  
 # if [ -z "$CORS_ALLOWED_HEADERS" ] || [ "${CORS_ALLOWED_HEADERS}" = null ]; then
 # CORS_ALLOWED_HEADERS="empty"
 # fi
  
 # if [ -z "$CORS_EXPOSE_HEADERS" ] || [ "${CORS_EXPOSE_HEADERS}" = null ]; then
 # CORS_EXPOSE_HEADERS="empty"
  #fi
  
 # sh cors-policy-update.sh $CORS_ALLOWED_ORIGINS $CORS_ALLOW_CREDENTIALS $CORS_ALLOWED_METHODS $CORS_CACHE_PERIOD_MAX_SECONDS $CORS_ALLOWED_HEADERS $CORS_EXPOSE_HEADERS
    
#else
 # sed -i "s#@CORS@##g" update-policy.sh
#fi
#################################################################################

#ip filter policy updates in template
#if [ "${IP_ADDRESS_TO_ALLOW}" != null ] && [ -n "${IP_ADDRESS_TO_FORBID}" != null ]; then
 # echo "**********"Both Allow and Forbid IPs/ranges present which is not expected. Exiting as failure**********"";
 # exit 1;
#fi

#if [ "${IP_ADDRESS_TO_ALLOW}" != null ]; then
 # sh ip-filter-allow-policy-update.sh $IP_ADDRESS_TO_ALLOW
#else
 # sed -i "s#@IP_FILTER_ALLOW_IP_ADDRESSES@##g" update-policy.sh
#fi

#if [ "${IP_ADDRESS_TO_FORBID}" != null ]; then
 # sh ip-filter-forbid-policy-update.sh $IP_ADDRESS_TO_FORBID
#else
 # sed -i "s#@IP_FILTER_FORBID_IP_ADDRESSES@##g" update-policy.sh
#fi
#################################################################################

#Backend oAUTH call
#if [ "${BACKEND_OAUTH_PROVIDER_URL}" != null ]; then
#  sh backend-oauth-policy-update.sh $BACKEND_OAUTH_PROVIDER_URL $BACKEND_OAUTH_CLIENT_ID $BACKEND_OAUTH_CLIENT_SECRET
#else
 # sed -i "s#@BACKEND_OAUTH_INBOUND@##g" update-policy.sh
 # sed -i "s#@BACKEND_OAUTH_OUTBOUND@##g" update-policy.sh
#fi

#################################################################################

#rate limit policy updates in template
if [ "${RATE_LIMIT_VALUE}" != null ]; then
  sh rate-limit-policy-update.sh $RATE_LIMIT_VALUE $RATE_LIMIT_COUNTER_KEY
else
  sed -i 's/<rate-limit-by-key[^>]*\/>//g' update-policy.sh;
fi  
#################################################################################



#Inbound Headers policy in template  ##Santosh
if [ "${ACCEPT_HEADERS}" != null ]; then
	sh caching-policy-update.sh $ACCEPT_HEADERS	
else
	sed -i "s#@ACCEPT_HEADERS_INBOUND@##g" update-policy.sh
fi

#Outbound Cache Duration policy in template  ##Santosh
if [ "${CACHE_DURATION}" != null ]; then
        sh outbound-caching-policy-update.sh $CACHE_DURATION
else
        sed -i "s#@CACHE_DURATION_OUTBOUND@##g" update-policy.sh
fi


#apply policies
sh -x update-policy.sh
