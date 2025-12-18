locals {
  endpoint_map = {
    for state in var.firewall_status : state.availability_zone => state.attachment[0].endpoint_id
  }
}

# 0.0.0.0/0 route for the 3 TGW Route Tables
resource "aws_route" "tgw_to_firewall" {
  count                  = length(var.azs)
  route_table_id         = var.tgw_route_table_ids[count.index] 
  destination_cidr_block = "0.0.0.0/0"

  vpc_endpoint_id = lookup(local.endpoint_map, var.azs[count.index])
}

# ::/0 (IPv6) route for the 3 TGW Route Tables
resource "aws_route" "tgw_to_firewall_ipv6" {
  count                       = length(var.azs)
  route_table_id              = var.tgw_route_table_ids[count.index]
  destination_ipv6_cidr_block = "::/0"
  
  vpc_endpoint_id = lookup(local.endpoint_map, var.azs[count.index])
}

# 0.0.0.0/0 route for the single Firewall Route Table
resource "aws_route" "fw_to_tgw" {
  route_table_id         = var.fw_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}

# ::/0 (IPv6) route for the single Firewall Route Table
resource "aws_route" "fw_to_tgw_ipv6" {
  route_table_id              = var.fw_route_table_id
  destination_ipv6_cidr_block = "::/0"
  transit_gateway_id          = var.transit_gateway_id
}