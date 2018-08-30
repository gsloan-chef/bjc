#!/bin/sh
# Usage and help
USAGE="Usage: $0 [STACKNAME]"

if [[ $# -eq 1 ]]; then
  NAME="${1}"
else
  NAME="${USER}"
fi

aws cloudformation describe-stacks --output json | jq -r '.[] | .[] | select(.StackName | contains("'"$NAME"'")) | ["\(.StackName)", "\(.Outputs | .[]? | .OutputValue)"] | @tsv' | awk -v FS="\t" 'BEGIN {printf("%-69s %-25s\n" ,"\033[32mStackName\033[0m", "\033[32mWorkstationIP\033[0m")}{printf("%-60s %-16s\n", $1, $2==""?"(building)":$2)}'
