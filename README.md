
```shell
export BITWARDEN_ACCOUNT=<CHANGEME>
SECRETS=$(bw get item VotingAppDeployment)
export TF_VAR_exoscale_api_key=$(echo $SECRETS jq -r '.fields[] | select(.name == "EXO_IAM_KEY").value')
export TF_VAR_exoscale_secret_key=$(echo $SECRETS jq -r '.fields[] | select(.name == "EXO_IAM_SECRET").value')
bw get attachment 5voeqewsipoltm6j9498j8842nmvh6un --itemid a68b0d64-6308-4fa7-bb1b-b2730098bb5f --output config/private_key.pem
(cd terraform && \
    terraform init && \
    terraform plan)
```
