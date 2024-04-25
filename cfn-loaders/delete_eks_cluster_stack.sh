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
aws cloudformation wait stack-delete-complete --stack-name Eks-NodeGroup-Stack-CF
aws cloudformation delete-stack --stack-name Eks-Cluster-Stack-CF
aws dynamodb delete-item \
  --table-name SecStoreAndMoreAdmin \
  --key "{\"ResourceIdentifier\": {\"S\": \"SecStoreEksClusterEndpoint\"}}"