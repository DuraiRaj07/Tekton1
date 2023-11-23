#!/bin/bash

BACKEND_OAUTH_PROVIDER_URL=$1
echo "BACKEND_OAUTH_PROVIDER_URL - " $BACKEND_OAUTH_PROVIDER_URL
BACKEND_OAUTH_CLIENT_ID=$2
echo "BACKEND_OAUTH_CLIENT_ID - " $BACKEND_OAUTH_CLIENT_ID
BACKEND_OAUTH_CLIENT_SECRET=$3
echo "BACKEND_OAUTH_CLIENT_SECRET - " $BACKEND_OAUTH_CLIENT_SECRET
BACKEND_OAUTH_POLICY=$4
echo "BACKEND_OAUTH_POLICY - " $BACKEND_OAUTH_POLICY

BACKEND_OAUTH_POLICY_INBOUND="<choose><when condition=\\\\\"@(!context.Variables.ContainsKey(\\\\\"bearerToken\\\\\"))\\\\\"><send-request mode=\\\\\"new\\\\\" response-variable-name=\\\\\"accessTokenResult\\\\\" timeout=\\\\\"60\\\\\" ignore-error=\\\\\"true\\\\\"><set-url>$BACKEND_OAUTH_PROVIDER_URL</set-url><set-method>Post</set-method><set-header name=\\\\\"Content-Type\\\\\" exists-action=\\\\\"override\\\\\"><value>application/x-www-form-urlencoded</value></set-header><set-body>@{return \\\\\"grant_type=client_credentials&client_id=$BACKEND_OAUTH_CLIENT_ID&client_secret=$BACKEND_OAUTH_CLIENT_SECRET\\\\\";}</set-body></send-request><set-variable name=\\\\\"accessToken\\\\\" value=\\\\\"@(((IResponse)context.Variables[\\\\\"accessTokenResult\\\\\"]).Body.As<JObject>())\\\\\" /><set-variable name=\\\\\"bearerToken\\\\\" value=\\\\\"@((string)((JObject)context.Variables[\\\\\"accessToken\\\\\"])[\\\\\"access_token\\\\\"])\\\\\" /><set-variable name=\\\\\"tokenDurationSeconds\\\\\" value=\\\\\"@((int)((JObject)context.Variables[\\\\\"accessToken\\\\\"])[\\\\\"expires_in\\\\\"])\\\\\" /><cache-store-value key=\\\\\"bearerToken\\\\\" value=\\\\\"@((string)context.Variables[\\\\\"bearerToken\\\\\"])\\\\\" duration=\\\\\"@((int)context.Variables[\\\\\"tokenDurationSeconds\\\\\"])\\\\\" /></when></choose><set-header name=\\\\\"Authorization\\\\\" exists-action=\\\\\"override\\\\\"><value>@(\\\\\"Bearer \\\\\" + (string)context.Variables[\\\\\"bearerToken\\\\\"])</value></set-header>"

BACKEND_OAUTH_POLICY_OUTBOUND="<choose><when condition=\\\\\"@(context.Response.StatusCode == 401 || context.Response.StatusCode == 403)\\\\\"><cache-remove-value key=\\\\\"bearerToken\\\\\" /></when></choose>"

if [ "${CORS_POLICY}" == api ]; then

    sed -i "s#@BACKEND_OAUTH_INBOUND@#${BACKEND_OAUTH_POLICY_INBOUND//&/\\&}#g" update-policy.sh;

    sed -i "s#@BACKEND_OAUTH_OUTBOUND@#${BACKEND_OAUTH_POLICY_OUTBOUND//&/\\&}#g" update-policy.sh;
else
    sed -i "s#@BACKEND_PRODUCT_OAUTH_INBOUND@#${BACKEND_OAUTH_POLICY_INBOUND//&/\\&}#g" update-policy.sh;

    sed -i "s#@BACKEND_PRODUCT_OAUTH_OUTBOUND@#${BACKEND_OAUTH_POLICY_OUTBOUND//&/\\&}#g" update-policy.sh;
fi

exit 0;
