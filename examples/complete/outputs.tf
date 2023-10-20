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


output "random_int" {
  description = "Random Int postfix"
  value       = random_integer.priority.result
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpce_sg_id" {
  value = module.ecs_platform.vpce_sg_id
}

output "ecs_sg_id" {
  value = module.sg_ecs_service.security_group_id
}

output "fargate_arn" {
  value = module.ecs_platform.fargate_arn
}

output "service_id" {
  value = module.ecs_alb_service_task.service_name
}

output "autoscaling_target_arn" {
  value = module.autoscaling_target.arn
}

output "autoscaling_target_id" {
  value = module.autoscaling_target.id
}
