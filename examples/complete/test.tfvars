naming_prefix = "demo"

interface_vpc_endpoints = {
  ecr-dkr = {
    service_name        = "ecr.dkr"
    private_dns_enabled = true
  }
  ecr-api = {
    service_name        = "ecr.api"
    private_dns_enabled = true
  }
  ecs = {
    service_name        = "ecs"
    private_dns_enabled = true
  }
  logs = {
    service_name        = "logs"
    private_dns_enabled = true
  }
}

gateway_vpc_endpoints = {
  s3 = {
    service_name        = "s3"
    private_dns_enabled = true
  }
}

vpce_security_group = {
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

ecs_security_group = {
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

container_image = "778189110199.dkr.ecr.us-east-2.amazonaws.com/sample-http:0.0.5"
container_port  = "8080"

min_capacity = 1
max_capacity = 4
