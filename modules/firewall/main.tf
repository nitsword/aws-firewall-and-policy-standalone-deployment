locals {
  all_firewall_subnet_ids  = var.firewall_subnet_ids
  first_firewall_subnet_id = var.firewall_subnet_ids[0]
  fw_name = "${var.application}-${var.env}-inspection-firewall-${var.region}"

  firewall_eni_details = [
    for state in aws_networkfirewall_firewall.inspection_firewall.firewall_status[0].sync_states :
    {
      subnet_id   = state.attachment[0].subnet_id
      endpoint_id = state.attachment[0].endpoint_id
    }
  ]
  first_firewall_eni_id = local.firewall_eni_details[0].endpoint_id
}

# -------------------------------------------------------------------------
# 4. Network Firewall Resource
# -------------------------------------------------------------------------
resource "aws_networkfirewall_firewall" "inspection_firewall" {
  name                = local.fw_name
  firewall_policy_arn = var.firewall_policy_arn
  vpc_id              = var.vpc_id

dynamic "subnet_mapping" {
    for_each = var.subnet_mapping
    content {
      subnet_id = subnet_mapping.value.subnet_id
    }
  }
    
  delete_protection = false
  description       = "Inspection VPC Firewall"

  tags = merge(
  {
    Name                  = "${var.application}-${var.env}-firewall-${var.region}"
    "Resource Type"       = "firewall"
    "Creation Date"       = timestamp()
    "Environment"         = var.environment
    "Application" = var.application
    "Created by"          = "Cloud Network Team"
    "Region"              = var.region
  },var.base_tags
)
}

data "aws_network_interface" "first_firewall_eni_ip_lookup" {
  depends_on = [aws_networkfirewall_firewall.inspection_firewall]
  
  filter {
    name   = "description"
    values = ["VPC Endpoint Interface ${local.first_firewall_eni_id}"] 
  }
}