if [ -z "${AWS_PROFILE}" ]; then
    echo "'AWS_PROFILE' not set."
    exit 1
fi
aws cloudformation delete-stack \
  --stack-name Eks-Rds-SS-Stack-CF \
  --profile $AWS_PROFILE
aws dynamodb delete-item \
  --table-name SecStoreAndMoreAdmin \
  --key "{\"ResourceIdentifier\": {\"S\": \"SecStoreRDSUri\"}}" \
  --profile $AWS_PROFILE