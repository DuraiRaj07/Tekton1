#echo $AZURE_SUBSCRIPTION_ID
#echo $AZURE_GROUP_NAME
#echo $AZURE_API_SERVICE_NAME
#echo $AZURE_API_ID

az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/apis/${AZURE_API_ID}/policies/policy?api-version=2021-08-01 --body '{"properties": {"method": "PUT","value": "<policies><inbound>@VALIDATE_JWT@@CORRELATION_ID@@CORS@@IP_FILTER_ALLOW_IP_ADDRESSES@@IP_FILTER_FORBID_IP_ADDRESSES@@BACKEND_OAUTH_INBOUND@@ACCEPT_HEADERS_INBOUND@<rate-limit-by-key calls=\"AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT\" renewal-period=\"AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL\" counter-key=\"@RATE_LIMIT_COUNTER_KEY@\" /></inbound><outbound>@BACKEND_OAUTH_OUTBOUND@@CACHE_DURATION_OUTBOUND@</outbound></policies>","format": "rawxml"}}'

#az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/apis/${AZURE_API_ID}/policies/policy?api-version=2021-08-01 --body '{"properties": {"method": "PUT","value": "<policies><inbound><rate-limit-by-key calls=\"AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT\" renewal-period=\"AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL\" counter-key=\"@RATE_LIMIT_COUNTER_KEY@\" /></inbound><outbound></outbound></policies>","format": "rawxml"}}'

#az rest --method PUT --uri https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_GROUP_NAME}/providers/Microsoft.ApiManagement/service/${AZURE_API_SERVICE_NAME}/apis/${AZURE_API_ID}/policies/policy?api-version=2021-08-01 --body '{"properties": {"method": "PUT","value": "<policies><inbound>@CORS@@IP_FILTER_ALLOW_IP_ADDRESSES@@IP_FILTER_FORBID_IP_ADDRESSES@@BACKEND_OAUTH_INBOUND@<rate-limit-by-key calls=\"AZURE_API_TRAFFIC_ARREST_LIMIT_COUNT\" renewal-period=\"AZURE_API_TRAFFIC_ARREST_LIMIT_INTERVAL\" counter-key=\"@RATE_LIMIT_COUNTER_KEY@\" /></inbound><outbound>@BACKEND_OAUTH_OUTBOUND@</outbound></policies>","format": "rawxml"}}'
