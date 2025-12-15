# Purpose
This repository mainly use terraform to create AWS EC2 and deploy Docker.

# Usage
1. AWS login with CLI
```
# AWS CLI assume role
export AWS_ACCOUNT_ID="your_account_id"
export AWS_ROLE_NAME="your_role_name"
aws sts assume-role --role-arn arn:aws:iam::$AWS_ACCOUNT_ID\:role/$AWS_ROLE_NAME --role-session-name "CLI-Session" --profile default > /tmp/aws_creds.json

# Setup the IAM credentials
export AWS_ACCESS_KEY_ID=$(cat /tmp/aws_creds.json | grep AccessKeyId | cut -d '"' -f 4)
export AWS_SECRET_ACCESS_KEY=$(cat /tmp/aws_creds.json | grep SecretAccessKey | cut -d '"' -f 4)
export AWS_SESSION_TOKEN=$(cat /tmp/aws_creds.json | grep SessionToken | cut -d '"' -f 4)
```

2. Execute AWS CLI to create s3 bucket, it's used for Terraform state file.
```
export AWS_BUCKET_NAME="$AWS_ACCOUNT_ID-terraform-state"
export AWS_REGION="ap-northeast-1"
aws s3api create-bucket --bucket $AWS_BUCKET_NAME --region $AWS_REGION --create-bucket-configuration LocationConstraint="$AWS_REGION"
```

3. Enable Versioning for S3 bucket
```
aws s3api put-bucket-versioning \
    --bucket $AWS_BUCKET_NAME \
    --versioning-configuration Status=Enabled
```

4. Enable server side encryption
```
aws s3api put-bucket-encryption \
    --bucket $AWS_BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'
```

5. Block all public access for s3
```
aws s3api put-public-access-block \
    --bucket $AWS_BUCKET_NAME \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

6. Create DynamoDB Table for State Locking (Optional)
Use the Amazon DynamoDB table to store the lock to prevent concurrent access to the terraform.tfstate file.
```
aws dynamodb create-table \
    --table-name terraform-state-lock-table \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region $AWS_REGION
```

7. Initialize Terraform
```
cd ./modules
terraform init -backend-config="bucket=795359014551-terraform-state"
```

8. Create EC2
```
terraform apply -target=module.ec2-docker -var-file="aws-docker.tfvars"
```