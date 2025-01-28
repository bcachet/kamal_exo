
```shell
export BITWARDEN_ACCOUNT=<CHANGEME>
# Exoscale IAM key to deploy our infra
SECRETS=$(bw get item VotingAppDeployment)
export TF_VAR_exoscale_api_key=$(echo $SECRETS | jq -r '.fields[] | select(.name == "EXO_IAM_KEY").value')
export TF_VAR_exoscale_secret_key=$(echo $SECRETS | jq -r '.fields[] | select(.name == "EXO_IAM_SECRET").value')
# Token to access ghcr.io registry
export GHCRIO=$(bw get password GHCRIO)
(cd terraform && \
    terraform init && \
    terraform plan)
kamal setup
```

Validate that vote application work:
```shell
$ curl -X POST -H "Content-Type: application/json" -d '{"vote": "foo"}' http://159.100.242.73:80
{"hostname":"159.100.242.73-19bc3792a704","voter_id":"910797520b4cd4"}
```