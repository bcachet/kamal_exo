## Deploy application on Exoscale with Kamal

Objective is to deploy a _vote_ application written in Python (relying on a Redis DB) and _vote-ui_ application written in JS (and serve by NGinx) onto Exoscale cloud provider using [Kamal](https://kamal-deploy.org).

> [!NOTE]
> We will create our infrastructure on Exoscale using [Terraform](https://terraform.io) 

### Gathering credentials

> [!NOTE]
> You will need an Exoscale account that you can obtain via https://portal.exoscale.com/register/
> Once created you will need IAM keys that you can found on https://portal.exoscale.com/u/<YOUR_ACCOUNT_NAME>/iam/keys

> [!NOTE]
> You also need a Github Personal Access Token to be able to Push/Pull to/from ghcr.io
> You can create one from https://github.com/settings/tokens

Once you have Exoscale IAM keys and Github Personal Access Token you can create environment variables that we will use against Terraform to create our infrastructure.
```shell
bw login
# Exoscale IAM key to deploy our infra
SECRETS=$(bw get item VotingAppDeployment)
export TF_VAR_exoscale_api_key=$(echo $SECRETS | jq -r '.fields[] | select(.name == "EXO_IAM_KEY").value')
export TF_VAR_exoscale_secret_key=$(echo $SECRETS | jq -r '.fields[] | select(.name == "EXO_IAM_SECRET").value')
# Token to access ghcr.io registry
export TF_VAR_ghcrio_token=$(bw get password GHCRIO)
```

### Creating/scaling infrastructure with Terraform

Creating the infrastructure
```shell
(cd terraform && \
    terraform init && \
    terraform apply)
```


### Deploying our applications with Kamal
Once our infrastructure is in place and our `.env` file has been populated by Terraform with IPs of our differents instances, we can deploy our application using Kamal
```shell
source .env # to load generated SSH key
(cd vote && kamal setup)
(cd vote && kamal deploy)
(cd vote-ui && kamal deploy)
(cd worker && kamal deploy)
```

### Validation of our setup
Once our applications have been deployed, we can do some validations

Validate that vote application work:
```shell
source .env
$ curl -X POST -H "Content-Type: application/json" -H "Host: vote" -d '{"vote": "foo"}' http://$WEB_NLB
```
Should return something like
```json
{"hostname":"159.100.242.73-19bc3792a704","voter_id":"910797520b4cd4"}
```

Then we can validate that UI is working as expected:
```shell
curl http://$WEB_NLB
```
Which should return some HTML content about Cats/Dogs

## Kamal on a daily basis

### Cheking status of our deployment

`kamal audit` will report status of our application and accessories

### Application lifecycle

`kamal app logs` will show logs our application

`kamal app exec <COMMAND>` will allow to execute a command inside the application container

### Maintenance

`kamal app containers` to retrieve the version we want to rollback to

`kamal rollback <VERSION>` to rollback application to a given version


### Servers handling

`kamal server exec --roles=vote <COMMAND>`

### Secrets handling

`kamal secrets`