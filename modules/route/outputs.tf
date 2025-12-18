/*
output "private_tg_route_table_ids" {
  description = "IDs of route tables for private_tg subnets (one per AZ)"
  value       = aws_route.private_tg[*].id
}

output "firewall_route_table_id" {
  description = "ID of the single route table for all private_firewall subnets"
  value       = aws_route.firewall.id
}*/