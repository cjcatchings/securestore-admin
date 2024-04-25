echo "Create SS RDS DB for our app database..."
./cfn-loaders/load_rds_ss_stack.sh
[ $? -eq 0 ]  || exit 1
echo "Now create FckNat Stack allow NAT for our private resources..."
./cfn-loaders/load_fnat_stack.sh
[ $? -eq 0 ]  || exit 1
echo "Now create EKS cluster to run SS on K8s..."
./cfn-loaders/load_eks_cluster_stack.sh
[ $? -eq 0 ]  || exit 1
echo "Now create EKS node group so our K8s cluster has some nodes..."
./cfn-loaders/load_eks_nodegroup_stack.sh
[ $? -eq 0 ]  || exit 1
echo "Now configure kubectl for our EKS cluster, create an OIDC provider \
for the cluster, an IAM service account and install the EKS LoadBalancer Controller"
./cfn-loaders/setup_kubectl_and_install_lbc.sh
[ $? -eq 0 ]  || exit 1
echo "Done!"