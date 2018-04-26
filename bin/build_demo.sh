#!/bin/bash
# Builds Chef Demo environment with a Cloudformation template

# Usage and help
USAGE="Usage: $0 [demo-version] [customer name or description] [your aws key name] [hours to keep the demo up] [your name] [your department] [your region]\n\nExample:\n$0 1.2.0 'Paper Street' \$AWS_KEYPAIR_NAME 4 'Tyler Durden' 'Sales' 'NA-East'"

if [[ $# -ne 7 ]]; then
  echo -e $USAGE
  exit 1
fi

# Variables
VERSION=$1
CUSTOMER=$2
CUSTOMER="${CUSTOMER// /-}"
SSH_KEY=$3
TTL=$4
CONTACT=$5
DEPARTMENT=$6
REGION=$7
TERMINATION_DATE="$(TZ=Etc/UTC date -j -v +$4H +'%Y-%m-%dT%H:%M:%SZ')"
REGION=us-west-2

# Here's where we create the stack
aws cloudformation create-stack \
--stack-name "${USER}-${CUSTOMER}-Chef-Demo-$(TZ=Etc/UTC date +'%Y%m%dT%H%M%SZ')" \
--capabilities CAPABILITY_IAM \
--region $REGION \
--tags Key=X-TTL,Value=${TTL} Key=TTL,Value=${TTL} Key=X-Contact,Value="${CONTACT}" Key=X-Dept,Value="${DEPARTMENT}" Key=X-Customer,Value="${CUSTOMER}" Key=X-Project,Value="BJC-Demo" Key=X-Termination-Date,Value=${TERMINATION_DATE} Key=X-Application,Value="${REGION}" \
--template-url https://s3-us-west-2.amazonaws.com/bjcpublic/cloudformation/bjc-demo-${VERSION}.json \
--parameters ParameterKey=KeyName,ParameterValue=${SSH_KEY} ParameterKey=TTL,ParameterValue=${TTL}
