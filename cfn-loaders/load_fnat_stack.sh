if [ -z "${AWS_PROFILE}" ]; then
    echo "'AWS_PROFILE' not set.  Consider setting this variable in a local env."
fi
EXISTING_STACK=$(aws cloudformation list-stacks \
    --stack-status-filter CREATE_COMPLETE \
    --output text \
    --query "StackSummaries[?StackName=='Eks-FckNat-Stack-CF'].StackName")
if ! [ -n ${EXISTING_STACK} ]; then
    echo "'${EXISTING_STACK}' already exists.  In the future let's call update-stack..."
    exit 0
fi
aws cloudformation deploy \
    --template-file $(dirname "$0")/../amazon-fcknat-cfn.yaml \
    --stack-name Eks-FckNat-Stack-CF \
    --capabilities "[\"CAPABILITY_IAM\"]"