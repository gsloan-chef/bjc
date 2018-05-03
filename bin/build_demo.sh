#!/bin/bash
# Builds Chef Demo environment with a Cloudformation template

# Usage and help
USAGE="Usage: $0 [cloud platform] [demo-version] [customer name or description] [your aws key name] [hours to keep the demo up] [your name] [your department] [your region]\n\nExample:\n$0 aws 1.2.0 'Paper Street' \$AWS_KEYPAIR_NAME 4 'Tyler Durden' 'Sales' 'NA-East'"

if [[ $# -ne 8 ]]; then
  echo -e $USAGE
  exit 1
fi

# Variables
CLOUD=$1
VERSION=$2
CUSTOMER=$3
CUSTOMER="${CUSTOMER// /-}"
SSH_KEY=$4
TTL=$5
CONTACT=$6
DEPARTMENT=$7
APPLICATION=$8

CLOUD=$(echo $CLOUD | tr '[:upper:]' '[:lower:]')
STACK_NAME="${USER}-${CUSTOMER}-Chef-Demo-$(TZ=Etc/UTC date +'%Y%m%dT%H%M%SZ')"
TERMINATION_DATE="$(TZ=Etc/UTC date -j -v +$5H +'%Y-%m-%dT%H:%M:%SZ')"
REGION_AWS=us-west-2
REGION_AZURE=westus

# Here's where we create the stack
# Hat-tip to @russellseymour for the Azure bits
case ${CLOUD} in
  aws)
    echo "Creating ${CLOUD} ${VERSION} demo..."

    aws cloudformation create-stack \
    --stack-name "${STACK_NAME}" \
    --capabilities CAPABILITY_IAM \
    --`region` $REGION_AWS \
    --tags Key=X-TTL,Value=${TTL} Key=TTL,Value=${TTL} Key=X-Contact,Value="${CONTACT}" Key=X-Dept,Value="${DEPARTMENT}" Key=X-Customer,Value="${CUSTOMER}" Key=X-Project,Value="BJC-Demo" Key=X-Termination-Date,Value=${TERMINATION_DATE} Key=X-Application,Value="${APPLICATION}" \
    --template-url https://s3-us-west-2.amazonaws.com/bjcpublic/cloudformation/bjc-demo-${CLOUD}-${VERSION}.json \
    --parameters ParameterKey=KeyName,ParameterValue=${SSH_KEY} ParameterKey=TTL,ParameterValue=${TTL}
    ;;
  azure)
    echo "Creating ${CLOUD} ${VERSION} demo..."

    az group create \
    -l $REGION_AZURE \
    -n "${STACK_NAME}" \
    --tags X-TTL=${TTL} TTL=${TTL} X-Contact="${CONTACT}" X-Dept="${DEPARTMENT}" X-Customer="${CUSTOMER}" X-Project="BJC-Demo" X-Termination-Date=${TERMINATION_DATE} X-Application="${APPLICATION}"

    az group deployment create \
    -g "${STACK_NAME}" \
    --template-uri https://s3-us-west-2.amazonaws.com/bjcpublic/cloudformation/bjc-demo-${CLOUD}-${VERSION}.json
    ;;
  *)
    echo "${CLOUD} cloud platform is not currently supported"
    echo "Please submit an issue to https://github/chef-cft/bjc to request a new platform."
  ;;
esac
