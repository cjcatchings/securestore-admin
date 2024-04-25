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
eksctl delete iamserviceaccount --cluster $EKS_CLUSTER_NAME \
 --namespace=kube-system \
 --name=aws-load-balancer-controller
OIDC_ARN=$(aws dynamodb get-item \
  --profile $AWS_PROFILE \
  --table-name SecStoreAndMoreAdmin \
  --key "{\"ResourceIdentifier\":{\"S\": \"${EKS_CLUSTER_NAME}-OIDCProviderArn\"}}" \
  --output text \
  --query 'Item.Value.S')
aws iam delete-open-id-connect-provider \
  --profile $AWS_PROFILE \
  --open-id-connect-provider-arn $OIDC_ARN
aws dynamodb delete-item \
  --table-name SecStoreAndMoreAdmin \
  --key "{\"ResourceIdentifier\":{\"S\": \"${EKS_CLUSTER_NAME}-OIDCProviderArn\"}}" \
  --profile $AWS_PROFILE
aws cloudformation delete-stack --stack-name Eks-NodeGroup-Stack-CF --profile $AWS_PROFILE
aws eks delete-access-entry --cluster-name $EKS_CLUSTER_NAME --principal-arn $EKS_CADMIN_ARN --profile $AWS_PROFILE