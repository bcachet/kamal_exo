# requires TF_VAR_exoscale_api_key env var
# eg: `TF_VAR_exoscale_api_key=foo terraform apply`
variable "exoscale_api_key" {
}

# requires TF_VAR_exoscale_secret_key env var
# eg: `TF_VAR_exoscale_secret_key=foo terraform apply`
variable "exoscale_secret_key" {
}

# requires TF_VAR_ghcrio_token env var
# eg: `TF_VAR_ghcrio_token=foo terraform apply`
variable "ghcrio_token" {
}

variable "zone" {
  default = "ch-gva-2"
}