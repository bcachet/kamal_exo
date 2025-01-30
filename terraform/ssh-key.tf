resource "tls_private_key" "deployment_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "exoscale_ssh_key" "deployment_ssh_key" {
  name       = "kamal-deployment-ssh-key"
  public_key = tls_private_key.deployment_ssh_key.public_key_openssh
}

# # Output private key to a file that will be used to SSH to created instances
# # Another approach can be to extract public key from a private key that has been provided
# resource "local_file" "deployment_ssh_key" {
#   content         = tls_private_key.deployment_ssh_key.private_key_pem
#   filename        = "../config/private_key.pem"
#   file_permission = "0400"
# }
