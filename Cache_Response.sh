CACHE_DURATION=$1

if [ -z "$CACHE_DURATION" ]; then
    echo "Please provide proper Integer value"
else

    if [ "${CACHE_POLICY}" == api ]; then

        INBOUND_POLICY_XML="<cache-lookup vary-by-developer=\\\"false\\\" vary-by-developer-groups=\\\"false\\\" allow-private-response-caching=\\\"false\\\" must-revalidate=\\\"false\\\" downstream-caching-type=\\\"none\\\" />"
        HEADERS_INBOUND_POLICY=${INBOUND_POLICY_XML//\"/\\\"}
        sed -i "s#@ACCEPT_HEADERS_INBOUND@#${HEADERS_INBOUND_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@ACCEPT_PRODUCT_HEADERS_INBOUND@##g" update-policy.sh
        OUTBOUND_POLICY_XML="<cache-store duration=\\\"$CACHE_DURATION\\\" />"
        echo $OUTBOUND_POLICY_XML
        CACHE_DURATION_POLICY=${OUTBOUND_POLICY_XML//\"/\\\"}
        sed -i "s#@CACHE_DURATION_OUTBOUND@#${CACHE_DURATION_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@CACHE_PRODUCT_DURATION_OUTBOUND@##g" update-policy.sh

    else

        INBOUND_POLICY_XML="<cache-lookup vary-by-developer=\\\"false\\\" vary-by-developer-groups=\\\"false\\\" allow-private-response-caching=\\\"false\\\" must-revalidate=\\\"false\\\" downstream-caching-type=\\\"none\\\" />"
        HEADERS_INBOUND_POLICY=${INBOUND_POLICY_XML//\"/\\\"}
        sed -i "s#@ACCEPT_PRODUCT_HEADERS_INBOUND@#${HEADERS_INBOUND_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@ACCEPT_HEADERS_INBOUND@##g" update-policy.sh
        OUTBOUND_POLICY_XML="<cache-store duration=\\\"$CACHE_DURATION\\\" />"
        echo $OUTBOUND_POLICY_XML
        CACHE_DURATION_POLICY=${OUTBOUND_POLICY_XML//\"/\\\"}
        sed -i "s#@CACHE_PRODUCT_DURATION_OUTBOUND@#${CACHE_DURATION_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@CACHE_DURATION_OUTBOUND@##g" update-policy.sh


    fi
fi

echo "POLICY_XML=$HEADERS_INBOUND_POLICY $CACHE_DURATION_POLICY"
