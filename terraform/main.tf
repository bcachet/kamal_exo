resource"local_file""instances_addresses" {
 content  = templatefile("dotenv.tftpl",
    { redis_instance = exoscale_compute_instance.redis, 
      web_instances = exoscale_instance_pool.web-ipool.instances.*,
      ssh_key = tls_private_key.deployment_ssh_key})
 filename = "../.env"
}