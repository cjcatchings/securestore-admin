if [ -z "${AWS_PROFILE}" ]; then
    echo "'AWS_PROFILE' not set."
    exit 1
fi
if [ -z "${EKS_CLUSTER_NAME}" ]; then
    echo "'AWS_PROFILE' not set."
    exit 1
fi
if [ -z "${EKS_CADMIN_ARN}" ]; then
    echo "'EKS_CADMIN_ARN' not set."
    exit 1
fi
aws cloudformation wait stack-delete-complete --stack-name Eks-NodeGroup-Stack-CF --profile $AWS_PROFILE
aws cloudformation delete-stack --stack-name Eks-Cluster-Stack-CF --profile $AWS_PROFILE
: 'aws iam delete-open-id-connect-provider --open-id-connect-provider-arn none --profile $AWS_PROFILE'
aws dynamodb delete-item \
  --table-name SecStoreAndMoreAdmin \
  --key "{\"ResourceIdentifier\": {\"S\": \"SecStoreEksClusterEndpoint\"}}" \
  --profile $AWS_PROFILE