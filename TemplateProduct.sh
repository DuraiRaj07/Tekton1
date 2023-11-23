#echo $AZURE_SUBSCRIPTION_ID

#echo $AZURE_GROUP_NAME

#echo $AZURE_API_SERVICE_NAME

#echo $AZURE_API_ID

AZURE_SUBSCRIPTION_ID=ac4234ff-d0ab-4634-b3c6-6179a9607144

AZURE_GROUP_NAME=coetg

AZURE_API_SERVICE_NAME=COEAPIManagement

PRODUCTNAME="MyProduct" 
PRODUCTNAME1="New Product"

APILIST="apinew123,echo-api,createproduct"


 echo $PRODUCTNAME

IFS=','
read -a my_apilist<<<"$APILIST"
az login --service-principal --username a2f6a4c7-f317-49ff-a01b-9f07cb29911e --password ksv8Q~cq8DQ~woq7L2K.z0B.subwzC2aD3_Lndnh --tenant 9b396b5e-cc54-4b14-bd0b-5fb84f196255
 

if [ "${PRODUCTNAME}" != "null" ]; then

        az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/products/$PRODUCTNAME?api-version=2022-08-01 --body "{\"properties\": {\"displayName\": \"${PRODUCTNAME1}\"}}"
    for ((i = 0; i < ${#my_apilist[@]}; i++)); do
        az rest --method PUT --uri https://management.azure.com/subscriptions/ac4234ff-d0ab-4634-b3c6-6179a9607144/resourceGroups/coetg/providers/Microsoft.ApiManagement/service/COEAPIManagement/products/Luminex/apis/${my_apilist[i]}?api-version=2021-08-01
        echo "az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/products/$PRODUCTNAME/apis/${my_apilist[i]}?api-version=2021-08-01"
    done    

        az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/products/$PRODUCTNAME/policies/policy?api-version=2021-08-01 --body '{"properties": {"format": "xml","value": "<policies><inbound>@VALIDATE_JWT@@CORRELATION_ID@@CORS@@IP_FILTER_ALLOW_IP_ADDRESSES@@IP_FILTER_FORBID_IP_ADDRESSES@@BACKEND_OAUTH_INBOUND@@ACCEPT_HEADERS_INBOUND@<rate-limit-by-key calls=\"AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT\" renewal-period=\"AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL\" counter-key=\"@RATE_LIMIT_COUNTER_KEY@\" /></inbound><outbound>@BACKEND_OAUTH_OUTBOUND@@CACHE_DURATION_OUTBOUND@@CORRELATION_OUTBOUND@</outbound></policies>","format": "rawxml"}}'

else

    az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/apis/${AZURE_API_ID}/policies/policy?api-version=2021-08-01 --body '{"properties": {"method": "PUT","value": "<policies><inbound>@VALIDATE_JWT@@CORRELATION_ID@@CORS@@IP_FILTER_ALLOW_IP_ADDRESSES@@IP_FILTER_FORBID_IP_ADDRESSES@@BACKEND_OAUTH_INBOUND@@ACCEPT_HEADERS_INBOUND@<rate-limit-by-key calls=\"AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT\" renewal-period=\"AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL\" counter-key=\"@RATE_LIMIT_COUNTER_KEY@\" /></inbound><outbound>@BACKEND_OAUTH_OUTBOUND@@CACHE_DURATION_OUTBOUND@@CORRELATION_OUTBOUND@</outbound></policies>","format": "rawxml"}}'

fi