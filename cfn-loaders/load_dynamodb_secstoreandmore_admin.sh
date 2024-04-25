if [ -z "${AWS_PROFILE}" ]; then
    echo "'AWS_PROFILE' not set."
    exit -1
fi
aws cloudformation deploy \
  --template-file ../amazon-dynamodb-admin.cfn.yaml \
  --stack-name SecStore-Admin-Db-CF
aws dynamodb put-item \
  --table-name SecStoreAndMoreAdmin \
  --item "{\"ResourceIdentifier\": {\"S\": \"SecStoreAndMoreAdminDbArn\"}, \"Value\": {\"S\": \"$(aws cloudformation describe-stacks --stack-name SecStore-Admin-Db-CF --query 'Stacks[0].Outputs[?OutputKey==`SecStoreandMoreAdminArn`].OutputValue' --output text)\"}}"