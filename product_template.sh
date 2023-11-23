#echo $AZURE_SUBSCRIPTION_ID
#echo $AZURE_GROUP_NAME
#echo $AZURE_API_SERVICE_NAME
#echo $AZURE_API_ID

#export AZURE_SUBSCRIPTION_ID=ac4234ff-d0ab-4634-b3c6-6179a9607144
#export AZURE_GROUP_NAME=coetg
#export AZURE_API_SERVICE_NAME=COEAPIManagement
#export CI_PROJECT_NAME=employeeapplication

#APILIST="apinew123,echo-api,createproduct"

#PRODUCTNAME=TESTINGPRODUCT
echo $PRODUCTNAME

IFS=','
read -a my_apilist<<<"$APILIST"


#az login --service-principal --username a2f6a4c7-f317-49ff-a01b-9f07cb29911e --password ksv8Q~cq8DQ~woq7L2K.z0B.subwzC2aD3_Lndnh --tenant 9b396b5e-cc54-4b14-bd0b-5fb84f196255

if [ "${TYPE}" == Product ]; then

	if [ "${PRODUCTNAME}" != null ]; then
		az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/products/${PRODUCTNAME}?api-version=2022-08-01 --body "{\"properties\":{\"displayName\": \"${PRODUCTNAME}\"}}"

		for ((i = 0; i < ${#my_apilist[@]}; i++)); do

			az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/products/${PRODUCTNAME}/apis/${my_apilist[i]}?api-version=2021-08-01 --body '{"properties":{"format": "xml","value": ""}}'

		done

		if [[ $FILTER_POLICY == "product" || $BACKEND_OAUTH_POLICY == "product" || $RATE_POLICY == "product" || $CACHE_POLICY == "product" || $CORRELATION_POLICY == "product" || $JWT_POLICY == "product" ]]; then

			az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/products/${PRODUCTNAME}/policies/policy?api-version=2021-08-01 --body '{"properties": {"format": "rawxml","value": "<policies><inbound>@VALIDATE_PRODUCT_JWT@@CORRELATION_PRODUCT_ID@@IP_FILTER_ALLOW_PRODUCT_IP_ADDRESSES@@IP_FILTER_FORBID_PRODUCT_IP_ADDRESSES@@BACKEND_PRODUCT_OAUTH_INBOUND@@ACCEPT_PRODUCT_HEADERS_INBOUND@<rate-limit-by-key calls=\"AZURE_API_TRAFFIC_PRODUCT_ARREST_LIMIT_COUNT\" renewal-period=\"AZURE_API_TRAFFIC_PRODUCT_ARREST_LIMIT_INTERVAL\" counter-key=\"@RATE_LIMIT_PRODUCT_COUNTER_KEY@\" /></inbound><outbound>@BACKEND_PRODUCT_OAUTH_OUTBOUND@@CACHE_PRODUCT_DURATION_OUTBOUND@@CORRELATION_PRODUCT_OUTBOUND@</outbound></policies>"}}'

			if [[ $FILTER_POLICY == "api" || $BACKEND_OAUTH_POLICY == "api" || $RATE_POLICY == "api" || $CACHE_POLICY == "api" || $CORRELATION_POLICY == "api" || $JWT_POLICY == "api" || @CORS_POLICY@ == "api" ]]; then

				az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/apis/${AZURE_API_ID}/policies/policy?api-version=2021-08-01 --body '{"properties": {"method": "PUT","value": "<policies><inbound>@VALIDATE_JWT@@CORRELATION_ID@@CORS@@IP_FILTER_ALLOW_IP_ADDRESSES@@IP_FILTER_FORBID_IP_ADDRESSES@@BACKEND_OAUTH_INBOUND@@ACCEPT_HEADERS_INBOUND@<rate-limit-by-key calls=\"AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT\" renewal-period=\"AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL\" counter-key=\"@RATE_LIMIT_COUNTER_KEY@\" /></inbound><outbound>@BACKEND_OAUTH_OUTBOUND@@CACHE_DURATION_OUTBOUND@@CORRELATION_OUTBOUND@</outbound></policies>","format": "rawxml"}}'

			fi
		else

			az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/apis/${AZURE_API_ID}/policies/policy?api-version=2021-08-01 --body '{"properties": {"method": "PUT","value": "<policies><inbound>@VALIDATE_JWT@@CORRELATION_ID@@CORS@@IP_FILTER_ALLOW_IP_ADDRESSES@@IP_FILTER_FORBID_IP_ADDRESSES@@BACKEND_OAUTH_INBOUND@@ACCEPT_HEADERS_INBOUND@<rate-limit-by-key calls=\"AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT\" renewal-period=\"AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL\" counter-key=\"@RATE_LIMIT_COUNTER_KEY@\" /></inbound><outbound>@BACKEND_OAUTH_OUTBOUND@@CACHE_DURATION_OUTBOUND@@CORRELATION_OUTBOUND@</outbound></policies>","format": "rawxml"}}'

		fi


	fi

elif [ "${TYPE}" == API ]; then

	if [[ $FILTER_POLICY == "product" || $BACKEND_OAUTH_POLICY == "product" || $RATE_POLICY == "product" || $CACHE_POLICY == "product" || $CORRELATION_POLICY == "product" || $JWT_POLICY == "product" ]]; then

		az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/products/${PRODUCTNAME}?api-version=2022-08-01 --body "{\"properties\":{\"displayName\": \"${PRODUCTNAME}\"}}"

		az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/products/${PRODUCTNAME}/policies/policy?api-version=2021-08-01 --body '{"properties": {"format": "rawxml","value": "<policies><inbound>@VALIDATE_PRODUCT_JWT@@CORRELATION_PRODUCT_ID@@IP_FILTER_ALLOW_PRODUCT_IP_ADDRESSES@@IP_FILTER_FORBID_PRODUCT_IP_ADDRESSES@@BACKEND_PRODUCT_OAUTH_INBOUND@@ACCEPT_PRODUCT_HEADERS_INBOUND@<rate-limit-by-key calls=\"AZURE_API_TRAFFIC_PRODUCT_ARREST_LIMIT_COUNT\" renewal-period=\"AZURE_API_TRAFFIC_PRODUCT_ARREST_LIMIT_INTERVAL\" counter-key=\"@RATE_LIMIT_PRODUCT_COUNTER_KEY@\" /></inbound><outbound>@BACKEND_PRODUCT_OAUTH_OUTBOUND@@CACHE_PRODUCT_DURATION_OUTBOUND@@CORRELATION_PRODUCT_OUTBOUND@</outbound></policies>"}}'

		if [[ $FILTER_POLICY == "api" || $BACKEND_OAUTH_POLICY == "api" || $RATE_POLICY == "api" || $CACHE_POLICY == "api" || $CORRELATION_POLICY == "api" || $JWT_POLICY == "api" ]]; then
		
			az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/apis/${AZURE_API_ID}/policies/policy?api-version=2021-08-01 --body '{"properties": {"method": "PUT","value": "<policies><inbound>@VALIDATE_JWT@@CORRELATION_ID@@CORS@@IP_FILTER_ALLOW_IP_ADDRESSES@@IP_FILTER_FORBID_IP_ADDRESSES@@BACKEND_OAUTH_INBOUND@@ACCEPT_HEADERS_INBOUND@<rate-limit-by-key calls=\"AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT\" renewal-period=\"AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL\" counter-key=\"@RATE_LIMIT_COUNTER_KEY@\" /></inbound><outbound>@BACKEND_OAUTH_OUTBOUND@@CACHE_DURATION_OUTBOUND@@CORRELATION_OUTBOUND@</outbound></policies>","format": "rawxml"}}'
		fi

	else

		az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/apis/${AZURE_API_ID}/policies/policy?api-version=2021-08-01 --body '{"properties": {"method": "PUT","value": "<policies><inbound>@VALIDATE_JWT@@CORRELATION_ID@@CORS@@IP_FILTER_ALLOW_IP_ADDRESSES@@IP_FILTER_FORBID_IP_ADDRESSES@@BACKEND_OAUTH_INBOUND@@ACCEPT_HEADERS_INBOUND@<rate-limit-by-key calls=\"AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT\" renewal-period=\"AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL\" counter-key=\"@RATE_LIMIT_COUNTER_KEY@\" /></inbound><outbound>@BACKEND_OAUTH_OUTBOUND@@CACHE_DURATION_OUTBOUND@@CORRELATION_OUTBOUND@</outbound></policies>","format": "rawxml"}}'

	fi


fi


