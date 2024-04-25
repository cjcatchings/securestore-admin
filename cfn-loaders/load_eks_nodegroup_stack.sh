if [ -z "${AWS_PROFILE}" ]; then
    echo "'AWS_PROFILE' not set."
    exit 1
fi
if [ -z "${EKS_CLUSTER_NAME}" ]; then
    echo "'EKS_CLUSTER_NAME' not set."
    exit 1
fi
if [ -z "${EKS_NODEGROUP_NAME}" ]; then
    echo "'EKS_NODEGROUP_NAME' not set."
    exit 1
fi
if [ -z "${EKS_CADMIN_ARN}" ]; then
    echo "'EKS_CADMIN_ARN' not set.  Defaulting to a blank string"
    EKS_CADMIN_ARN=""
fi
EXISTING_STACK=$(aws cloudformation list-stacks \
    --stack-status-filter CREATE_COMPLETE \
    --output text \
    --query "StackSummaries[?StackName=='Eks-NodeGroup-Stack-CF'].StackName" \
    --profile Elvira-PowerDevs)
if ! [ -n ${EXISTING_STACK} ]; then
    echo "'${EXISTING_STACK}' already exists."
    exit 0
fi
aws cloudformation deploy \
  --template-file $(dirname "$0")/../amazon-eks-nodegroup-cfn.yaml \
  --stack-name Eks-NodeGroup-Stack-CF \
  --capabilities "[\"CAPABILITY_IAM\", \"CAPABILITY_NAMED_IAM\"]" \
  --parameter-overrides ClusterName=$EKS_CLUSTER_NAME NodeGroupName=$EKS_NODEGROUP_NAME EksClusterAdminPrincipal=$EKS_CADMIN_ARN \
  --profile $AWS_PROFILE
[ $? -eq 0 ]  || exit 1