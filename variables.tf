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

variable "min_capacity" {
  description = "Min capacity of the scalable target."
  type        = number
}

variable "max_capacity" {
  description = "Max capacity of the scalable target."
  type        = number
}

variable "scalable_dimension" {
  description = <<EOF
    Scalable dimension of scalable target. Details to be found at
    https://docs.aws.amazon.com/autoscaling/application/APIReference/API_RegisterScalableTarget.html#API_RegisterScalableTarget_RequestParameters
  EOF
  type        = string
}

variable "service_namespace" {
  description = <<EOF
    AWS service namespace of the scalable target. Details to be found at
    https://docs.aws.amazon.com/autoscaling/application/APIReference/API_RegisterScalableTarget.html#API_RegisterScalableTarget_RequestParameters
  EOF
  type        = string
}

variable "resource_id" {
  description = <<EOF
    Resource type and unique identifier string for the resource associated with the scaling policy. Details found at
    https://docs.aws.amazon.com/autoscaling/application/APIReference/API_RegisterScalableTarget.html#API_RegisterScalableTarget_RequestParameters
  EOF
  type        = string
}

variable "role_arn" {
  description = <<EOF
    Optional ARN of the IAM role that allows Application AutoScaling to modify your scalable target on your behalf.
    This defaults to an IAM Service-Linked Role for most services and custom IAM Roles are ignored by the API
    for those namespaces.
  EOF
  type        = string
  default     = ""
}

variable "tags" {
  description = "An arbitrary map of tags that can be added to all resources."
  type        = map(string)
  default     = {}
}
