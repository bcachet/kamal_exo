# requires TF_VAR_exoscale_api_key env var
# eg: `TF_VAR_exoscale_api_key=foo terraform apply`
variable "exoscale_api_key" {
  default = "your-api-key-here"
}

# requires TF_VAR_exoscale_secret_key env var
# eg: `TF_VAR_exoscale_secret_key=foo terraform apply`
variable "exoscale_secret_key" {
  default =  "your-api-secret-here"
}

# requires TF_VAR_private_key env var
# eg: `TF_VAR_private_key=foo terraform apply`
variable "private_key" {
  default = "your-private-key-PEM-content"
}

variable "zone" {
  default = "ch-gva-2"
}