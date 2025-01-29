resource"local_file""instances_addresses" {
 content  = templatefile("dotenv.tftpl",
    { redis_instance = exoscale_compute_instance.redis, 
      web_instances_ips = join(" ", exoscale_instance_pool.web-ipool.instances.*.public_ip_address),
      web_nlb = exoscale_nlb.web-nlb,
      ssh_key = tls_private_key.deployment_ssh_key,
      ghcrio_token = var.ghcrio_token})
 filename = "../.env"
}