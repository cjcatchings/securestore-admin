if [ -z "${AWS_PROFILE}" ]; then
    echo "'AWS_PROFILE' not set."
    exit 1
fi
aws cloudformation delete-stack --stack-name Eks-FckNat-Stack-CF --profile $AWS_PROFILE