# Open-WebUI Deployed to AWS Beanstalk

- Docker Platform uses [Dockerrun.aws.json](Dockerrun.aws.json) to define the container configuration and environment variables
- See the list here: [https://docs.openwebui.com/getting-started/env-configuration/](https://docs.openwebui.com/getting-started/env-configuration/)

## Getting Started

Run your Open-WebUI instance on AWS Elastic Beanstalk and manage the infrastructure with Terraform. You can connect your API keys or use AWS Bedrock for LLM access.

### Deploy IAC

Deploy your beanstalk environment with Terraform:

```bash
# Initialize Terraform
terraform init
# Review the plan
terraform plan
# Apply the changes
terraform apply
```

### Deploy Application

Deploy the Open-WebUI application to your Beanstalk environment using the EB CLI:

```bash
# Initialize EB CLI
eb init --profile=atn-developer
# Review the status
eb status --profile=atn-developer
# Deploy the application
eb deploy --profile=atn-developer
```

- check on [chat.ejacquot.com](https://chat.ejacquot.com) (or your custom domain)

## Run locally

```bash
eb local run
```
