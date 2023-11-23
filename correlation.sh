#CORRELATIONID=$1
#TRACE=$2

if [ "${CORRELATIONID}" == "true" ] && [ "${TRACE}" == "true" ]; then
    INBOUND_POLICY_XML="<set-variable name=\\\"correlation-id\\\" value=\\\"@(Guid.NewGuid().ToString())\\\" /><set-header name=\\\"x-correlation-id\\\" exists-action=\\\"override\\\"><value>@((string)context.Variables[\\\"correlation-id\\\"])</value></set-header><trace source=\\\"Global APIM Policy\\\" severity=\\\"information\\\"><message>@(String.Format(\\\"{0} | {1}\\\", context.Api.Name, context.Operation.Name))</message><metadata name=\\\"correlation-id\\\" value=\\\"@((string)context.Variables[\\\"correlation-id\\\"])\\\" /></trace>"
     
     HEADERS_INBOUND_POLICY=${INBOUND_POLICY_XML//\"/\\\"}

     
    if [ "${CORRELATION_POLICY}" == api ]; then

        sed -i "s#@CORRELATION_ID@#${HEADERS_INBOUND_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@CORRELATION_PRODUCT_ID@##g" update-policy.sh
    else
        sed -i "s#@CORRELATION_PRODUCT_ID@#${HEADERS_INBOUND_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@CORRELATION_ID@##g" update-policy.sh

    fi

    OUTBOUND_POLICY_XML="<set-header name=\\\"x-correlation-id\\\" exists-action=\\\"override\\\"><value>@((string)context.Variables[\\\"correlation-id\\\"])</value></set-header>"
    
    HEADERS_OUTBOUND_POLICY=${OUTBOUND_POLICY_XML//\"/\\\"}

    if [ "${CORRELATION_POLICY}" == api ]; then
    
        sed -i "s#@CORRELATION_OUTBOUND@#${HEADERS_OUTBOUND_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@CORRELATION_PRODUCT_OUTBOUND@##g" update-policy.sh
    else
        sed -i "s#@CORRELATION_PRODUCT_OUTBOUND@#${HEADERS_OUTBOUND_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@CORRELATION_OUTBOUND@##g" update-policy.sh
    
    fi

elif [ "${CORRELATIONID}" == "true" ]; then
    INBOUND_POLICY_XML="<set-variable name=\\\"correlation-id\\\" value=\\\"@(Guid.NewGuid().ToString())\\\" /><set-header name=\\\"x-correlation-id\\\" exists-action=\\\"override\\\"><value>@((string)context.Variables[\\\"correlation-id\\\"])</value></set-header>"
    
    HEADERS_INBOUND_POLICY=${INBOUND_POLICY_XML//\"/\\\"}

    if [ "${CORRELATION_POLICY}" == api ]; then

        sed -i "s#@CORRELATION_ID@#${HEADERS_INBOUND_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@CORRELATION_PRODUCT_ID@##g" update-policy.sh

    else
        sed -i "s#@CORRELATION_PRODUCT_ID@#${HEADERS_INBOUND_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@CORRELATION_ID@##g" update-policy.sh
    fi

     OUTBOUND_POLICY_XML="<set-header name=\\\"x-correlation-id\\\" exists-action=\\\"override\\\"><value>@((string)context.Variables[\\\"correlation-id\\\"])</value></set-header>"
    
    HEADERS_OUTBOUND_POLICY=${OUTBOUND_POLICY_XML//\"/\\\"}

    if [ "${CORRELATION_POLICY}" == api ]; then
    
        sed -i "s#@CORRELATION_OUTBOUND@#${HEADERS_OUTBOUND_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@CORRELATION_PRODUCT_OUTBOUND@##g" update-policy.sh
    else
        sed -i "s#@CORRELATION_PRODUCT_OUTBOUND@#${HEADERS_OUTBOUND_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@CORRELATION_OUTBOUND@##g" update-policy.sh
    fi
   
else
    echo "do nothing"
fi

echo  "policy=$INBOUND_POLICY_XML"
