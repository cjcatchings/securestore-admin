if [ -z "${AWS_PROFILE}" ]; then
    echo "'AWS_PROFILE' not set."
    exit 1
fi
EXISTING_STACK=$(aws cloudformation list-stacks \
    --stack-status-filter CREATE_COMPLETE \
    --output text \
    --query "StackSummaries[?StackName=='Eks-FckNat-Stack-CF'].StackName" \
    --profile Elvira-PowerDevs)
if ! [ -n ${EXISTING_STACK} ]; then
    echo "'${EXISTING_STACK}' already exists."
    exit 0
fi
aws cloudformation deploy \
    --template-file $(dirname "$0")/../amazon-fcknat-cfn.yaml \
    --stack-name Eks-FckNat-Stack-CF \
    --capabilities "[\"CAPABILITY_IAM\"]" \
    --profile $AWS_PROFILE
[ $? -eq 0 ]  || exit 1