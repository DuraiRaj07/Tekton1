#!/bin/bash

ACCEPT_HEADERS=$1
#ACCEPT_HEADERS="Accept,Authorization,Accept-Charset"
echo $ACCEPT_HEADERS

VARY_BY_HEADER_XML=""


if [ "${ACCEPT_HEADERS}" != null ]; then
    IFS=',' read -ra SELECTED_HEADERS <<< "$ACCEPT_HEADERS"

    echo "Selected Headers:"
    for header in "${SELECTED_HEADERS[@]}"; do
        echo "Header: $header"
        VARY_BY_HEADER_XML+="<vary-by-header>${header}</vary-by-header>"
    done

    echo "VARY_BY_HEADER_XML:"
    echo -e "$VARY_BY_HEADER_XML"

    # Corrected POLICY_XML assignment with proper quotes and variable interpolation
    INBOUND_POLICY_XML="<cache-lookup vary-by-developer=\\\"true\\\" vary-by-developer-groups=\\\"true\\\" allow-private-response-caching=\\\"true\\\" must-revalidate=\\\"true\\\" downstream-caching-type=\\\"public\\\">${VARY_BY_HEADER_XML}</cache-lookup>"
    #ESCAPED_POLICY_XML=$(echo "$INBOUND_POLICY_XML" | sed 's/"/\\\\"/g')
    echo "POLICY_XML:"
    echo "$INBOUND_POLICY_XML"
    export INBOUND_POLICY_XML	
	
    HEADERS_INBOUND_POLICY=${INBOUND_POLICY_XML//\"/\\\"}

    if [ "${CACHE_POLICY}" == api ]; then

        sed -i "s#@ACCEPT_HEADERS_INBOUND@#${HEADERS_INBOUND_POLICY//&/\\&}#g" update-policy.sh
    else
        sed -i "s#@ACCEPT_PRODUCT_HEADERS_INBOUND@#${HEADERS_INBOUND_POLICY//&/\\&}#g" update-policy.sh
    fi   

else
    echo "Something went wrong"
fi
