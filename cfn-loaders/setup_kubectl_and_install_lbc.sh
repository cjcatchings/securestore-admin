if [ -z "${AWS_PROFILE}" ]; then
    echo "'AWS_PROFILE' not set."
    exit -1
fi
if [ -z "${EKS_CLUSTER_NAME}" ]; then
    echo "'EKS_CLUSTER_NAME' not set."
    exit -1
fi
if [ -z "${EKS_CADMIN_ARN}" ]; then
    echo "'EKS_CADMIN_ARN' not set."
    exit -1
fi
if [ -z "${EKS_LBC_POLICY_ARN}" ]; then
    echo "'EKS_LBC_POLICY_ARN' not set."
    exit -1
fi
if [ -z "${EKS_REGION}" ]; then
    echo "'EKS_REGION' not set.  Setting to eu-central-1..."
    EKS_REGION = eu-central-1
fi
AWS_ACCT_ID=$(aws sts get-caller-identity --query Account --output text)
aws eks update-kubeconfig --region $EKS_REGION --name $EKS_CLUSTER_NAME --profile $AWS_PROFILE --role $EKS_CADMIN_ARN
[ $? -eq 0 ]  || exit 1
kubectl config set-credentials arn:aws:eks:$EKS_REGION:$AWS_ACCT_ID:cluster/$EKS_CLUSTER_NAME \
  --exec-command=aws \
  --exec-arg=--region \
  --exec-arg=$EKS_REGION \
  --exec-arg=eks \
  --exec-arg=get-token \
  --exec-arg=--cluster-name \
  --exec-arg=$EKS_CLUSTER_NAME \
  --exec-arg=--output \
  --exec-arg=json \
  --exec-arg=--profile \
  --exec-arg=$AWS_PROFILE
[ $? -eq 0 ]  || exit 1
eksctl utils associate-iam-oidc-provider \
 --region=$EKS_REGION \
 --cluster=$EKS_CLUSTER_NAME \
 --profile $AWS_PROFILE \
 --approve
[ $? -eq 0 ]  || exit 1
eksctl create iamserviceaccount --cluster $EKS_CLUSTER_NAME \
 --namespace=kube-system \
 --name=aws-load-balancer-controller \
 --role-name=AmazonEKSLoadBalancerControllerRole \
 --attach-policy-arn=$EKS_LBC_POLICY_ARN --approve --profile $AWS_PROFILE
 # Uncomment below if you have not installed the EKS Helm repo
 #helm repo add eks https://aws.github.io/eks-charts
 [ $? -eq 0 ]  || exit 1
 helm repo update eks
 helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
 -n kube-system \
 --set clusterName=$EKS_CLUSTER_NAME \
 --set serviceAccount.create=false \
 --set serviceAccount.name=aws-load-balancer-controller
[ $? -eq 0 ]  || exit 1

for OIDC_ARN in $(aws iam list-open-id-connect-providers \
  --profile Elvira-PowerDevs --output text \
  --query 'OpenIDConnectProviderList[?contains(@.Arn,`oidc.eks`)]')
do
   CL_IS_SS=$(aws iam get-open-id-connect-provider \
     --profile Elvira-PowerDevs \
     --open-id-connect-provider-arn $OIDC_ARN \
     --output text \
     --query 'Tags[?contains(@.Key,`alpha.eksctl.io/cluster-name`)].Value')
   if [ $CL_IS_SS = $EKS_CLUSTER_NAME ]; then
        echo "OIDC provider found.  Adding it to admin table."
          aws dynamodb put-item \
            --table-name SecStoreAndMoreAdmin \
            --profile $AWS_PROFILE \
            --item "{\"ResourceIdentifier\": {\"S\": \"${EKS_CLUSTER_NAME}-OIDCProviderArn\"}, \"Value\": {\"S\": \"$OIDC_ARN\"}}"
        break
   else
        echo "OIDC provider not found."
   fi
done