# -------------------------------------------------------------
# Existing Variables
# -------------------------------------------------------------
variable "firewall_name" {
  description = "Name of the firewall"
  type        = string
}

variable "firewall_policy_name" {
  description = "Name of the firewall policy"
  type        = string
}

variable "firewall_policy_arn" {
  description = "ARN of the Network Firewall Policy created in the dedicated policy module."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where firewall is deployed"
  type        = string
}

variable "firewall_subnet_ids" {
  description = "List of subnet IDs for firewall endpoints"
  type        = list(string)
}

variable "subnet_mapping" {
  description = "List of subnet IDs for the firewall endpoints"
  type = list(object({
    subnet_id = string
  }))
}

variable "firewall_endpoint_cidr" {
  description = "The CIDR block used for traffic routing to the firewall."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the VPC"
  type        = map(string)
  default     = {}
}

variable "application" { type = string }
variable "environment" { type = string }
variable "region" { type = string }
variable "base_tags" { type = map(string) }
variable "env" { type = string }