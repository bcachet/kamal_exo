
```shell
export TF_VAR_exoscale_api_key=EXO<CHANGEME>
export TF_VAR_exoscale_secret_key=<CHANGEME>
(cd terraform && \
    terraform init && \
    terraform plan)
(cd terraform && \
    (terraform show -json \
    | jq -r .values.outputs.ssh_key.value \
    | tee ../ssh.key)) \
    && chmod 0600 ssh.key
```
