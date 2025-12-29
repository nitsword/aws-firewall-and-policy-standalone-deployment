terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54"
    }
  }
}


provider "aws" {
  region = var.region
}

locals {
  domain_list_data = csvdecode(file(var.rules_csv_path))
  allowed_domains = [
    for d in local.domain_list_data : trimspace(d.domain)
    if lookup(d, "action", "") != "" && upper(trimspace(d.action)) == "ALLOW"
  ]


  # allowed_domains = [
  # for row in local.domain_list_raw : trimspace(row.domain)
  # if can(row.action) && upper(trimspace(row.action)) == "ALLOW"
  # ]


  # domain_list_data = csvdecode(file(var.rules_csv_path))

  # # SIMPLIFIED: Only domain list will be provided no Action
  # allowed_domains = [
  #   for d in local.domain_list_data : trimspace(d.domain)
  # ]


  #  5-tuple CSV and build Suricata rule strings.
  # Expected CSV headers: action,protocol,source,source_port,destination,destination_port,msg,sid
  five_tuple_rules_data = csvdecode(file(var.five_tuple_rules_csv_path))

  five_tuple_rules = [
    for r in local.five_tuple_rules_data : {
      # FIX: Force Action and Protocol to UPPERCASE
      action   = upper(lookup(r, "action", "PASS"))
      protocol = upper(lookup(r, "protocol", "TCP"))

      source           = upper(lookup(r, "source", "ANY"))
      source_port      = upper(lookup(r, "source_port", "ANY"))
      destination      = upper(lookup(r, "destination", "ANY"))
      destination_port = upper(lookup(r, "destination_port", "ANY"))
      direction        = "FORWARD"
      sid              = tostring(lookup(r, "sid", "1000001"))
    }
  ]
}

data "aws_subnet" "firewall_subnets" {
  count = length(var.azs)

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name = "tag:Name"
    # Matches the strict naming standard from Repo 1
    values = ["${var.application}-${var.env}-pvt-subnet-fw-${var.azs[count.index]}"]
  }
}

# Find the 3 separate TGW/Traffic Source Route Tables
data "aws_route_table" "tgw_rts" {
  count = length(var.azs)

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name = "tag:Name"
    # Matches: ntw-dev-tg-rt-us-east-1a, etc.
    values = ["ntw-${var.env}-vpc-pvt-tg-subnet-rttb-${var.azs[count.index]}"]
  }
}

# Find the single Firewall Route Table
data "aws_route_table" "fw_rt" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name = "tag:Name"
    # Matches: ntw-dev-fw-rt-us-east-1
    values = ["ntw-${var.env}-vpc-pvt-fw-subnet-rttb-${var.region}"]
  }
}


module "firewall_policy_conf" {
  source                      = "./modules/firewall_policy_conf"
  environment                 = var.environment
  application                 = var.application
  region                      = var.region
  env                         = var.env
  base_tags                   = var.base_tags
  firewall_policy_name        = var.firewall_policy_name
  five_tuple_rg_capacity      = var.five_tuple_rg_capacity
  five_tuple_rules            = local.five_tuple_rules
  domain_list                 = local.allowed_domains
  enable_domain_allowlist     = var.enable_domain_allowlist
  domain_rg_capacity          = var.domain_rg_capacity
  stateful_rule_group_arns    = var.stateful_rule_group_arns
  stateful_rule_order         = var.stateful_rule_order
  stateful_rule_group_objects = var.stateful_rule_group_objects
  priority_domain_allowlist   = var.priority_domain_allowlist
  priority_five_tuple         = var.priority_five_tuple
}

module "firewall" {
  source                 = "./modules/firewall"
  application            = var.application
  environment            = var.environment
  region                 = var.region
  env                    = var.env
  base_tags              = var.base_tags
  firewall_name          = var.firewall_name
  firewall_policy_name   = var.firewall_policy_name
  vpc_id                 = var.vpc_id
  firewall_endpoint_cidr = var.firewall_endpoint_cidr
  firewall_policy_arn    = module.firewall_policy_conf.firewall_policy_arn
  firewall_subnet_ids    = data.aws_subnet.firewall_subnets[*].id
  subnet_mapping = [
    for s in data.aws_subnet.firewall_subnets : {
      subnet_id = s.id
    }
  ]
}


# Look up the bucket created in vpc setup repo
data "aws_s3_bucket" "nfw_logs" {
  bucket = "ntw-${var.env}-tmo-firewall-logs-bucket"
}

# Configure Logging
resource "aws_networkfirewall_logging_configuration" "this" {
  firewall_arn = module.firewall.firewall_arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        bucketName = data.aws_s3_bucket.nfw_logs.bucket
        prefix     = "alerts"
      }
      log_destination_type = "S3"
      log_type             = "ALERT"
    }
  }
}

module "routing" {
  source = "./modules/route"

  # Pass IDs discovered via Data Sources
  tgw_route_table_ids = data.aws_route_table.tgw_rts[*].id
  fw_route_table_id   = data.aws_route_table.fw_rt.id

  firewall_status = module.firewall.firewall_status[0].sync_states

  transit_gateway_id = var.transit_gateway_id
  azs                = var.azs
  application        = var.application
  environment        = var.environment
  region             = var.region
  env                = var.env
  base_tags          = var.base_tags
}

