variable "region" {
  description = "AWS region"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = []
}

variable "private_tg_cidrs" {
  description = "CIDRs for private TG subnets"
  type        = list(string)
  default     = []
}

variable "private_firewall_cidrs" {
  description = "CIDRs for private firewall subnets"
  type        = list(string)
  default     = []
}

# variable "private_tg_ipv6_cidrs" {
#   description = "IPv6 CIDRs for private TG subnets"
#   type        = list(string)
#   default     = []
# }

variable "private_firewall_ipv6_cidrs" {
  description = "IPv6 CIDRs for private firewall subnets"
  type        = list(string)
  default     = []
}

variable "firewall_name" {
  description = "Name of the firewall"
  type        = string
  default     = "inspection-firewall"
}

variable "firewall_policy_name" {
  description = "Name of the firewall policy"
  type        = string
  default     = "inspection-firewall-policy"
}

variable "private_firewall_subnet_ids" {
  description = "List of private firewall subnet IDs"
  type        = list(string)
  default     = []
}

variable "private_tg_subnet_ids" {
  description = "List of private TG subnet IDs"
  type        = list(string)
  default     = []
}

variable "priority_domain_allowlist" {
  description = "Priority for the Domain ALLOWLIST rule group (STRICT_ORDER evaluation)."
  type        = number
}

variable "priority_five_tuple" {
  description = "Priority for the 5-Tuple rule group (STRICT_ORDER evaluation)."
  type        = number
}
variable "vpc_id" {
  type = string

}

variable "stateful_rule_group_arns" {
  description = "List of ARNs for stateful rule groups"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "List of public subnet IDs for the VPC"
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = []
}

variable "firewall_endpoint_cidr" {
  description = "CIDR for the Network Firewall Endpoints"
  type        = string
}

variable "firewall_subnet_ids" {
  description = "List of existing subnet IDs where the firewall endpoints are deployed."
  type        = list(string)
  default     = []
}


variable "five_tuple_rg_capacity" {
  description = "Capacity for the 5-Tuple rule group."
  type        = number
}


variable "domain_rg_capacity" {
  description = "Capacity for the Domain rule group."
  type        = number
}

variable "allowed_domains_list" {
  description = "FQDNs/domains for targets in the Domain List rule group."
  type        = list(string)
  default     = []
}

variable "enable_domain_allowlist" {
  type    = bool
  default = false
}

variable "rules_csv_path" {
  description = "Relative path to the environment-specific rule CSV file."
  type        = string
}

variable "five_tuple_rules_csv_path" {
  description = "Relative path to a CSV file containing structured 5-tuple rules"
  type        = string
  validation {
    condition     = length(var.five_tuple_rules_csv_path) > 0
    error_message = "five_tuple_rules_csv_path must be set and non-empty."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

variable "application" { type = string }
variable "environment" { type = string }
variable "env" { type = string }

variable "base_tags" {
  type    = map(string)
  default = { "Created by" = "Cloud Network Team" }
}

variable "stateful_rule_order" {
  description = "Stateful rule evaluation order for Network Firewall: 'STRICT_ORDER' or 'DEFAULT_ORDER'."
  type        = string
  default     = "STRICT_ORDER"
  validation {
    condition     = contains(["STRICT_ORDER", "DEFAULT_ORDER"], var.stateful_rule_order)
    error_message = "stateful_rule_order must be either STRICT_ORDER or DEFAULT_ORDER"
  }
}

variable "stateful_rule_group_objects" {
  description = "List of objects with ARN and priority for external stateful rule groups"
  type        = list(object({ arn = string, priority = number }))
  default     = []
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID"
  type        = string
}

/*
variable "secondary_cidr_blocks" {
  type        = list(string)
  description = "List of secondary IPv4 CIDR blocks passed from dev.tfvars"
}*/
