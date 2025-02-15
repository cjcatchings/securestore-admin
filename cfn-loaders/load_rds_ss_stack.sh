if [ -z "${AWS_PROFILE}" ]; then
    echo "'AWS_PROFILE' not set.  Consider setting this variable in a local env."
fi
if [ -z "${RDS_SS_SNAPSHOT}" ]; then
    echo "'RDS_SS_SNAPSHOT' not set."
    exit 1
fi
EXISTING_STACK=$(aws cloudformation list-stacks \
    --stack-status-filter CREATE_COMPLETE \
    --output text \
    --query "StackSummaries[?StackName=='Eks-Rds-SS-Stack-CF'].StackName")
if ! [ -n ${EXISTING_STACK} ]; then
    echo "'${EXISTING_STACK}' already exists.  In the future let's call update-stack..."
    exit 0
fi
aws cloudformation deploy \
  --template-file $(dirname "$0")/../amazon-rds-secstore-cfn.yaml \
  --stack-name Eks-Rds-SS-Stack-CF \
  --parameter-overrides "SnapshotIdentifierName=$RDS_SS_SNAPSHOT"

STACK_FAIL_REASONS=$(aws cloudformation describe-stack-events --stack-name Eks-Rds-SS-Stack-CF --max-items 2 \
  --query 'StackEvents[].ResourceStatusReason')
if [ -z ${STACK_FAIL_REASONS} ]; then
  echo "RDS stack creation failed: ${STACK_FAIL_REASONS}"
  exit 1
fi

if [ $(aws dynamodb list-tables --query "contains(TableNames, 'SecStoreAndMoreAdmin')") == true ]; then
  DBS_URI_RI="SecStoreRDSUri"
  echo "SecStoreAndMoreAdmin table found.  Saving RDS URL to RI $DBS_URI_RI."
  aws dynamodb put-item \
    --table-name SecStoreAndMoreAdmin \
    --item "{\"ResourceIdentifier\": {\"S\": \"$DBS_URI_RI\"}, \"Value\": {\"S\": \"$(aws cloudformation describe-stacks --stack-name Eks-Rds-SS-Stack-CF --query 'Stacks[0].Outputs[?OutputKey==`SecStoreRDSUrl`].OutputValue' --output text)\"}}"
else
  echo "SecStoreAndMoreAdmin table NOT found.  Not saving RDS URL."
fi