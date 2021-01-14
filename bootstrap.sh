S3_BUCKET="sre-infra-aws"
checkbucket() {
echo "S3_BUCKET=$S3_BUCKET"
if aws s3 ls "s3://$S3_BUCKET" | grep -q 'AllAccessDisabled'    
then
    echo "Please run aws s3 mb s3://$S3_BUCKET --region us-east-2"
    exit 1
fi
}
terraform_init() {
terraform workspace new development || true
terraform init
}
terraform_plan() {
    terraform plan 
}
terraform_apply() {
    terraform apply
}
next() {
echo "Do you wish to install this program?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) terraform_apply; break;;
        No ) exit;;
    esac
done
}
trap "cd ../" EXIT

{
checkbucket
cd ./terraform || exit
terraform_init
terraform_plan
next

aws eks --region us-east-2 update-kubeconfig --name sre-infra
}
