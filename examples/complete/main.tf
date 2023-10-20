// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

resource "random_integer" "priority" {
  min = 10000
  max = 50000
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                 = local.vpc_name
  cidr                 = var.vpc_cidr
  private_subnets      = var.private_subnets
  azs                  = var.availability_zones
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}

module "ecs_platform" {
  source = "git::https://github.com/nexient-llc/tf-aws-wrapper_module-ecs_appmesh_platform?ref=0.1.0"

  vpc_id                  = module.vpc.vpc_id
  private_subnets         = module.vpc.private_subnets
  gateway_vpc_endpoints   = var.gateway_vpc_endpoints
  interface_vpc_endpoints = var.interface_vpc_endpoints
  route_table_ids         = concat([module.vpc.default_route_table_id], module.vpc.private_route_table_ids)

  naming_prefix              = local.naming_prefix
  vpce_security_group        = var.vpce_security_group
  region                     = var.region
  environment                = var.environment
  environment_number         = var.environment_number
  resource_number            = var.resource_number
  container_insights_enabled = true

  namespace_name        = local.namespace_name
  namespace_description = "Namespace for testing appmesh ingress"

  tags = var.tags

  depends_on = [module.vpc]
}

# Security Group for ECS task
module "sg_ecs_service" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.17.1"

  vpc_id      = module.vpc.vpc_id
  name        = local.ecs_sg_name
  description = "Security Group for Application ECS Service"

  ingress_cidr_blocks      = coalesce(try(lookup(var.ecs_security_group, "ingress_cidr_blocks", []), []), [])
  ingress_rules            = coalesce(try(lookup(var.ecs_security_group, "ingress_rules", []), []), [])
  ingress_with_cidr_blocks = coalesce(try(lookup(var.ecs_security_group, "ingress_with_cidr_blocks", []), []), [])
  egress_cidr_blocks       = coalesce(try(lookup(var.ecs_security_group, "egress_cidr_blocks", []), []), [])
  egress_rules             = coalesce(try(lookup(var.ecs_security_group, "egress_rules", []), []), [])
  egress_with_cidr_blocks  = coalesce(try(lookup(var.ecs_security_group, "egress_with_cidr_blocks", []), []), [])

  tags = local.tags
}

module "container_definition" {
  source         = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.59.0"
  container_name = "app"
  # Docker image must already exist in ECR in the same account
  container_image  = var.container_image
  container_memory = "512"
  container_cpu    = "256"
  port_mappings = [
    {
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    }
  ]
}

module "ecs_alb_service_task" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "~> 0.69.0"

  namespace                          = "${local.naming_prefix}-${join("", split("-", var.region))}"
  stage                              = var.environment_number
  name                               = "svc"
  environment                        = var.environment
  attributes                         = [var.resource_number]
  delimiter                          = "-"
  alb_security_group                 = ""
  container_definition_json          = jsonencode([module.container_definition.json_map_object])
  ecs_cluster_arn                    = module.ecs_platform.fargate_arn
  launch_type                        = "FARGATE"
  vpc_id                             = module.vpc.vpc_id
  security_group_ids                 = [module.sg_ecs_service.security_group_id]
  subnet_ids                         = module.vpc.private_subnets
  tags                               = var.tags
  ignore_changes_task_definition     = false
  network_mode                       = "awsvpc"
  assign_public_ip                   = false
  health_check_grace_period_seconds  = 0
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  deployment_controller_type         = "ECS"
  desired_count                      = 1
  task_memory                        = 512
  task_cpu                           = 256
}

module "autoscaling_target" {
  source = "../.."

  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  resource_id        = "service/${split("/", module.ecs_platform.fargate_arn)[1]}/${module.ecs_alb_service_task.service_name}"
}
