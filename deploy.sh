#export AZURE_SUBSCRIPTION_ID=ac4234ff-d0ab-4634-b3c6-6179a9607144
#export AZURE_GROUP_NAME=coetg
#export AZURE_API_SERVICE_NAME=COEAPIManagement
#export CI_PROJECT_NAME=employeeapplication

#export RATE_LIMIT_VALUE=5pm
#export RATE_LIMIT_COUNTER_KEY=user-identity
#RATE_LIMIT_VALUE=

#export CLAIMS=null
#export CLAIMS_MATCH=null

#IP_ADDRESS_TO_FORBID="192.168.0.100, 10.0.0.10-to-10.0.0.20, 172.16.0.5, 30.0.0.10-to-30.0.0.20"
#export IP_ADDRESS_TO_ALLOW="192.168.1.50, 10.0.0.10-to-10.0.0.20, 172.16.0.20,30.0.0.10-to-30.0.0.20"
#IP_ADDRESS_TO_FORBID=null
#IP_ADDRESS_TO_ALLOW=null

#export CORS_ALLOWED_ORIGINS="http://api.example.com, https://demo.sample.com"
#CORS_ALLOWED_ORIGINS=""
#CORS_ALLOW_CREDENTIALS="true"
#CORS_ALLOW_CREDENTIALS="false"
#CORS_ALLOWED_METHODS="GET, POST"
#CORS_ALLOWED_METHODS="ALL"
#CORS_CACHE_PERIOD_MAX_SECONDS=200
#CORS_CACHE_PERIOD_MAX_SECONDS=""
#CORS_ALLOWED_HEADERS="Header1, header2, header3,header4"
#CORS_EXPOSE_HEADERS="EHeader1, Eheader2,Eheader3"
#CORS_EXPOSE_HEADERS=""

#BACKEND_OAUTH_PROVIDER_URL="https://alm-app-registry.auth.us-east-1.amazoncognito.com/OAUTH2/token"
#BACKEND_OAUTH_CLIENT_ID="2t7ri9otobvsbt9kcoau3eobol"
#BACKEND_OAUTH_CLIENT_SECRET="n85iohdn3r61dbo1cu62e0ckvonu1ha3s86tbnp38luvvp2stam"
#BACKEND_OAUTH_PROVIDER_URL=null
#BACKEND_OAUTH_CLIENT_ID=null
#BACKEND_OAUTH_CLIENT_SECRET=null

#export CACHE_DURATION=300
#export ACCEPT_HEADERS="Accept,Authorization,Accept-Charset"

echo "Project Name: "${CI_PROJECT_NAME}

echo "Values are - " ${RATE_LIMIT_VALUE} ${RATE_LIMIT_COUNTER_KEY} ${IP_ADDRESS_TO_ALLOW} ${IP_ADDRESS_TO_FORBID} ${CORS_ALLOWED_ORIGINS} ${CORS_ALLOW_CREDENTIALS} ${CORS_ALLOWED_METHODS} ${CORS_CACHE_PERIOD_MAX_SECONDS} ${CORS_ALLOWED_HEADERS} ${CORS_EXPOSE_HEADERS} ${BACKEND_OAUTH_PROVIDER_URL} ${BACKEND_OAUTH_CLIENT_ID} ${BACKEND_OAUTH_CLIENT_SECRET}

IP_ADDRESS_TO_FORBID=$(echo "$IP_ADDRESS_TO_FORBID" | tr -d '[:space:]')
IP_ADDRESS_TO_ALLOW=$(echo "$IP_ADDRESS_TO_ALLOW" | tr -d '[:space:]')


CORS_ALLOWED_ORIGINS=$(echo "$CORS_ALLOWED_ORIGINS" | tr -d '[:space:]')
CORS_ALLOWED_METHODS=$(echo "$CORS_ALLOWED_METHODS" | tr -d '[:space:]')
CORS_ALLOWED_HEADERS=$(echo "$CORS_ALLOWED_HEADERS" | tr -d '[:space:]')
CORS_EXPOSE_HEADERS=$(echo "$CORS_EXPOSE_HEADERS" | tr -d '[:space:]')

upload_format=$(awk '/openApiSpec:/ {split($2, a, "."); print a[length(a)]}' generate.yaml)

#Deploy API in Azure APIM
if [ "${upload_format}" == yaml ]; then
  AZURE_API_ID=$(az apim api import -g ${AZURE_GROUP_NAME} --api-id  ${CI_PROJECT_NAME} --display-name ${CI_PROJECT_NAME} --service-name ${AZURE_API_SERVICE_NAME} --path ${CI_PROJECT_NAME} --specification-path ./${CI_PROJECT_NAME}.yaml --specification-format OpenApi --subscription-required false | jq -r '.name')
elif [ "${upload_format}" == json ]; then
  AZURE_API_ID=$(az apim api import -g ${AZURE_GROUP_NAME} --api-id  ${CI_PROJECT_NAME} --display-name ${CI_PROJECT_NAME} --service-name ${AZURE_API_SERVICE_NAME} --path ${CI_PROJECT_NAME} --specification-path ./${CI_PROJECT_NAME}.json --specification-format OpenApiJson --subscription-required false | jq -r '.name')
elif [ "${upload_format}" == gql ]; then

  AZURE_API_ID=$(az apim api create --api-id ${CI_PROJECT_NAME} --display-name ${CI_PROJECT_NAME} --path ${CI_PROJECT_NAME} --resource-group ${AZURE_GROUP_NAME} --service-name ${AZURE_API_SERVICE_NAME} --api-type graphql | jq -r '.name')

  az apim api schema create --service-name ${AZURE_API_SERVICE_NAME} -g ${AZURE_GROUP_NAME} --api-id ${CI_PROJECT_NAME} --schema-id graphql --schema-type application/vnd.ms-azure-apim.graphql.schema --schema-path ./${CI_PROJECT_NAME}.gql
elif [ -z "$upload_format" ]; then
  AZURE_API_ID=$(az apim api import -g ${AZURE_GROUP_NAME} --api-id  ${CI_PROJECT_NAME} --display-name ${CI_PROJECT_NAME} --service-name ${AZURE_API_SERVICE_NAME} --path ${CI_PROJECT_NAME} --specification-path ./${CI_PROJECT_NAME}.yaml --specification-format OpenApi --subscription-required false | jq -r '.name')
fi

#AZURE_API_ID="employeeapplication"
echo ${AZURE_API_ID}

if [[ -z "$AZURE_API_ID" ]]; then 
  echo "**********Import failed. Check above for reasons. Exiting as failure**********";
  exit 1;
else
  echo "**********Deployed API without policies**********";
fi

export AZURE_API_ID=${AZURE_API_ID}


echo "**********Evaluvating policies**********"

#cp ./policy_template.sh ./update-policy.sh
cp ./product_template.sh ./update-policy.sh
#################################################################################

#CORS policy updates in template
if [ -n "${CORS_ALLOWED_ORIGINS}" ] && [ "${CORS_ALLOWED_ORIGINS}" != null ]; then

  if [ -z "$CORS_CACHE_PERIOD_MAX_SECONDS" ] || [ "${CORS_CACHE_PERIOD_MAX_SECONDS}" = null ]; then
  	CORS_CACHE_PERIOD_MAX_SECONDS="empty"
  fi
  
  if [ -z "$CORS_ALLOWED_HEADERS" ] || [ "${CORS_ALLOWED_HEADERS}" = null ]; then
  	CORS_ALLOWED_HEADERS="empty"
  fi
  
  if [ -z "$CORS_EXPOSE_HEADERS" ] || [ "${CORS_EXPOSE_HEADERS}" = null ]; then
 	 CORS_EXPOSE_HEADERS="empty"
  fi
  
  sh cors-policy-update.sh $CORS_ALLOWED_ORIGINS $CORS_ALLOW_CREDENTIALS $CORS_ALLOWED_METHODS $CORS_CACHE_PERIOD_MAX_SECONDS $CORS_ALLOWED_HEADERS $CORS_EXPOSE_HEADERS $CORS_POLICY_APPLY
    
else
  sed -i "s#@CORS@##g" update-policy.sh
  sed -i "s#@CO_RS_PRODUCT@##g" update-policy.sh
fi
#################################################################################

#ip filter policy updates in template
if [ "${IP_ADDRESS_TO_ALLOW}" != null ] && [ "${IP_ADDRESS_TO_FORBID}" != null ]; then
  echo "**********"Both Allow and Forbid IPs/ranges present which is not expected. Exiting as failure**********"";
  exit 1;
fi

if [ "${IP_ADDRESS_TO_ALLOW}" != null ]; then
  sh ip-filter-allow-policy-update.sh $IP_ADDRESS_TO_ALLOW $FILTER_POLICY
else
  sed -i "s#@IP_FILTER_ALLOW_IP_ADDRESSES@##g" update-policy.sh
  sed -i "s#@IP_FILTER_ALLOW_PRODUCT_IP_ADDRESSES@##g" update-policy.sh
fi

if [ "${IP_ADDRESS_TO_FORBID}" != null ]; then
  sh ip-filter-forbid-policy-update.sh $IP_ADDRESS_TO_FORBID $FILTER_POLICY
else
  sed -i "s#@IP_FILTER_FORBID_IP_ADDRESSES@##g" update-policy.sh
  sed -i "s#@IP_FILTER_FORBID_PRODUCT_IP_ADDRESSES@##g" update-policy.sh
fi
#################################################################################

#Backend oAUTH call
if [ "${BACKEND_OAUTH_PROVIDER_URL}" != null ]; then
  sh backend-oauth-policy-update.sh $BACKEND_OAUTH_PROVIDER_URL $BACKEND_OAUTH_CLIENT_ID $BACKEND_OAUTH_CLIENT_SECRET $BACKEND_OAUTH_POLICY
else
  sed -i "s#@BACKEND_OAUTH_INBOUND@##g" update-policy.sh
  sed -i "s#@BACKEND_OAUTH_OUTBOUND@##g" update-policy.sh
  sed -i "s#@BACKEND_PRODUCT_OAUTH_INBOUND@##g" update-policy.sh
  sed -i "s#@BACKEND_PRODUCT_OAUTH_OUTBOUND@##g" update-policy.sh
fi

#################################################################################

#rate limit policy updates in template
if [ "${RATE_LIMIT_VALUE}" != null ]; then
  sh rate-limit-policy-update.sh $RATE_LIMIT_VALUE $RATE_LIMIT_COUNTER_KEY $RATE_RENEWAL_PERIOD $RATE_POLICY
else
  sed -i 's/<rate-limit-by-key[^>]*\/>//g' update-policy.sh;
fi  
#################################################################################



#Inbound Headers policy in template  ##Santosh
#if [ "${ACCEPT_HEADERS}" != null ]; then
#	sh caching-policy-update.sh $ACCEPT_HEADERS	
#else
#	sed -i "s#@ACCEPT_HEADERS_INBOUND@##g" update-policy.sh
#fi

#Outbound Cache Duration policy in template  ##Santosh
#if [ "${CACHE_DURATION}" != null ]; then
#        sh outbound-caching-policy-update.sh $CACHE_DURATION
#else
#        sed -i "s#@CACHE_DURATION_OUTBOUND@##g" update-policy.sh
#fi

#HEADER_NAME=null

if [ "${HEADER_NAME}" != null ]; then
   sh validate_jwt.sh $HEADER_NAME $JWT_POLICY
else
   sed -i "s#@VALIDATE_JWT@##g" update-policy.sh
   sed -i "s#@VALIDATE_PRODUCT_JWT@##g" update-policy.sh
fi
###################################################################################

if [ "${CORRELATIONID}" == "true" ]; then
  sh correlation.sh $CORRELATIONID
else
  sed -i "s#@CORRELATION_ID@##g" update-policy.sh
  sed -i "s#@CORRELATION_OUTBOUND@##g" update-policy.sh
  sed -i "s#@CORRELATION_PRODUCT_ID@##g" update-policy.sh
  sed -i "s#@CORRELATION_PRODUCT_OUTBOUND@##g" update-policy.sh
fi


if [ "${CACHE_DURATION}" == null ]; then
        sed -i "s#@CACHE_DURATION_OUTBOUND@##g" update-policy.sh
        sed -i "s#@ACCEPT_HEADERS_INBOUND@##g" update-policy.sh
        sed -i "s#@CACHE_PRODUCT_DURATION_OUTBOUND@##g" update-policy.sh
        sed -i "s#@ACCEPT_PRODUCT_HEADERS_INBOUND@##g" update-policy.sh
else
      sh Cache_Response.sh $CACHE_DURATION
fi

###################################################################################



#apply policies
sh -x update-policy.sh
