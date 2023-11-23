#!/bin/bash

IP_ADDRESS_TO_FORBID=$1
echo "IP_ADDRESS_TO_FORBID - " $IP_ADDRESS_TO_FORBID

FILTER_POLICY=$2
echo "FILTER_POLICY - " $FILTER_POLICY

if [ -n "${IP_ADDRESS_TO_FORBID}" ]; then
  echo "Replacing IP_ADDRESS_TO_FORBID with user values"
  IP_FILTER_FORBID_IP_ADDRESSES_START="<ip-filter action=\\\"forbid\\\">"
  
  # Split the IP addresses by comma
  IFS=',' read -ra IP_ADDRESSES <<< "$IP_ADDRESS_TO_FORBID"
  
  # Initialize variables to store address ranges and individual addresses
  ADDRESS_RANGES=""
  INDIVIDUAL_ADDRESSES=""
  
  # Loop through each IP address
  for IP in "${IP_ADDRESSES[@]}"; do
    # Check if the IP address contains "-to-" for range
    if [[ $IP == *"-to-"* ]]; then
      # Split the range by "-to-"
      FROM_ADDRESS=$(echo "$IP" | awk -F'-to-' '{print $1}')
      TO_ADDRESS=$(echo "$IP" | awk -F'-to-' '{print $2}')
      
      # Add the address range to the variable
      ADDRESS_RANGES+="<address-range from=\\\"$FROM_ADDRESS\\\" to=\\\"$TO_ADDRESS\\\" />"
    else
      # Add individual address to the variable
      INDIVIDUAL_ADDRESSES+="<address>$IP</address>"
    fi
  done
  
  # Concatenate the address ranges and individual addresses
  IP_FILTER_FORBID_IP_ADDRESSES_MIDDLE="$ADDRESS_RANGES$INDIVIDUAL_ADDRESSES"
  
  # Concatenate the parts to form the final string
  IP_FILTER_FORBID_IP_ADDRESSES="$IP_FILTER_FORBID_IP_ADDRESSES_START$IP_FILTER_FORBID_IP_ADDRESSES_MIDDLE</ip-filter>"
  echo "$IP_FILTER_FORBID_IP_ADDRESSES"
  
  # Escape double quotes in the XML string
  ESCAPED_IP_FILTER_FORBID_IP_ADDRESSES=${IP_FILTER_FORBID_IP_ADDRESSES//\"/\\\"}
  
  # Replace the placeholder with the IP filter addresses using a different delimiter for sed
  if [ "${FILTER_POLICY}" == api ]; then
    sed -i "s#@IP_FILTER_FORBID_IP_ADDRESSES@#${ESCAPED_IP_FILTER_FORBID_IP_ADDRESSES//&/\\&}#g" update-policy.sh 
    sed -i "s#@IP_FILTER_FORBID_PRODUCT_IP_ADDRESSES@##g" update-policy.sh
  else
    sed -i "s#@IP_FILTER_FORBID_PRODUCT_IP_ADDRESSES@#${ESCAPED_IP_FILTER_FORBID_IP_ADDRESSES//&/\\&}#g" update-policy.sh
    sed -i "s#@IP_FILTER_FORBID_IP_ADDRESSES@##g" update-policy.sh
  fi
fi
