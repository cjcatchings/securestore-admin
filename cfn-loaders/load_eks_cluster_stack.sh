if [ -z "${AWS_PROFILE}" ]; then
    echo "'AWS_PROFILE' not set."
    exit 1
fi
if [ -z "${EKS_CLUSTER_NAME}"  ]; then
    echo "'EKS_CLUSTER_NAME' not set."
    exit 1
fi
EXISTING_STACK=$(aws cloudformation list-stacks \
    --stack-status-filter CREATE_COMPLETE \
    --output text \
    --query "StackSummaries[?StackName=='Eks-Cluster-Stack-CF'].StackName" \
    --profile $AWS_PROFILE)
if ! [ -n ${EXISTING_STACK} ]; then
    echo "'${EXISTING_STACK}' already exists."
    exit 0
fi
aws cloudformation deploy \
--template-file $(dirname "$0")/../amazon-eks-cluster-cfn.yaml \
--stack-name Eks-Cluster-Stack-CF \
--capabilities "[\"CAPABILITY_IAM\", \"CAPABILITY_NAMED_IAM\"]" \
--parameter-overrides "ClusterName=$EKS_CLUSTER_NAME" \
--profile $AWS_PROFILE
[ $? -eq 0 ]  || exit 1


if [ $(aws dynamodb list-tables --profile $AWS_PROFILE --query "contains(TableNames, 'SecStoreAndMoreAdmin')") == true ]; then
  EKS_CLUSTER_ENDPOINT="SecStoreEksClusterEndpoint"
  ENDPOINT_URL=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --output text --query 'cluster.endpoint')
  echo "SecStoreAndMoreAdmin table found.  Saving EKS Cluster Endpoint to RI $EKS_CLUSTER_ENDPOINT."
  aws dynamodb put-item \
    --table-name SecStoreAndMoreAdmin \
    --profile $AWS_PROFILE \
    --item "{\"ResourceIdentifier\": {\"S\": \"$EKS_CLUSTER_ENDPOINT\"}, \"Value\": {\"S\": \"$ENDPOINT_URL\"}}"
else
  echo "SecStoreAndMoreAdmin table NOT found.  Not saving EKS Cluster."
fi