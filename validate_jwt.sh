#!/bin/bash
#HEADER_NAME=$1
#FAILEDSTATUSCODE=$2
#FAILEDSTATUSMESSAGE=$3
#OPENIDURL="https://sit.identity.idmodule.eu/.well-known/openid-configuration"

echo "Exported Value"$FAILEDSTATUSMESSAGE
#HEADER_NAME=$1
#FAILEDSTATUSCODE=$FAILEDSTATUSCODE
#FAILEDSTATUSMESSAGE=$FAILEDSTATUSMESSAGE
#OPENIDURL=$4

# Your comma-separated string
#CLAIMS="aud","aud"
#CLAIMS_MATCH="any","all"

#CLAIMS=$5
#CLAIMS_MATCH=$6
#HEADER_NAME=null

if [ -z "$FAILEDSTATUSMESSAGE" ]; then
    FAILEDSTATUSMESSAGE="Token not available or invalid"
fi

if [ -z "$FAILEDSTATUSCODE" ]; then
    FAILEDSTATUSCODE=401
fi    

# Set the IFS to a comma (,) to split the string
IFS=','
REQUIRED_CLAIMS=""
# Read the CSV string into an array
read -a my_array <<< "$CLAIMS"
read -a my_array1 <<< "$CLAIMS_MATCH"

# Restore the original IFS
IFS=' '
echo "index element ${my_array[0]}"
echo "the length is ${#my_array[@]}"
echo "$FAILEDSTATUSCODE $FAILEDSTATUSMESSAGE"
# Print the elements of the array

if [ -z "$CLAIMS" ] && [ -z "$OPENIDURL" ]; then
    policy_xml="<validate-jwt header-name=\\\"$HEADER_NAME\\\" failed-validation-httpcode=\\\"$FAILEDSTATUSCODE\\\" failed-validation-error-message=\\\"$FAILEDSTATUSMESSAGE\\\" />"
    


elif [ -z "$CLAIMS" ]; then
    policy_xml="<validate-jwt header-name=\\\"$HEADER_NAME\\\" failed-validation-httpcode=\\\"$FAILEDSTATUSCODE\\\" failed-validation-error-message=\\\"$FAILEDSTATUSMESSAGE\\\"><openid-config url=\\\"$OPENIDURL\\\" /></validate-jwt>"
    


elif [ -z "$OPENIDURL" ]; then
    for ((i = 0; i < ${#my_array[@]}; i++)); do
    REQUIRED_CLAIMS+="<claim name=\\\"${my_array[i]}\\\" match=\\\"${my_array1[i]}\\\"/>"
    done

    policy_xml="<validate-jwt header-name=\\\"$HEADER_NAME\\\" failed-validation-httpcode=\\\"$FAILEDSTATUSCODE\\\" failed-validation-error-message=\\\"$FAILEDSTATUSMESSAGE\\\"><required-claims>$REQUIRED_CLAIMS</required-claims></validate-jwt>"

else 
    for ((i = 0; i < ${#my_array[@]}; i++)); do
    REQUIRED_CLAIMS+="<claim name=\\\"${my_array[i]}\\\" match=\\\"${my_array1[i]}\\\"/>"
    done
    policy_xml="<validate-jwt header-name=\\\"$HEADER_NAME\\\" failed-validation-httpcode=\\\"$FAILEDSTATUSCODE\\\" failed-validation-error-message=\\\"$FAILEDSTATUSMESSAGE\\\"><openid-config url=\\\"$OPENIDURL\\\" /><required-claims>$REQUIRED_CLAIMS</required-claims></validate-jwt>"
fi

HEADERS_INBOUND_POLICY=${policy_xml//\"/\\\"}

    if [ "${JWT_POLICY}" == api ]; then

        sed -i "s#@VALIDATE_JWT@#${HEADERS_INBOUND_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@VALIDATE_PRODUCT_JWT@##g" update-policy.sh
    else

        sed -i "s#@VALIDATE_PRODUCT_JWT@#${HEADERS_INBOUND_POLICY//&/\\&}#g" update-policy.sh
        sed -i "s#@VALIDATE_JWT@##g" update-policy.sh
    fi
   

echo "policy=$HEADERS_INBOUND_POLICY"

