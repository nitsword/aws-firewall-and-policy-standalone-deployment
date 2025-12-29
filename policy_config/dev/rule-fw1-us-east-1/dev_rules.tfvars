region = "us-east-1"
vpc_id = "vpc-0ad451614830a0875"
transit_gateway_id      = "tgw-09396a29da000e3c8"
azs         = ["us-east-1a", "us-east-1b", "us-east-1d"]
application = "ntw"
env         = "dev"
#rules_directory = "policy_config/dev/rules-fw1-us-east1"
environment          = "Non-production::Dev"

firewall_policy_name = "inspection-firewall-policy-dev"
firewall_endpoint_cidr = "0.0.0.0/0"
stateful_rule_order = "STRICT_ORDER"
 
priority_domain_allowlist = 10  # Second priority 
priority_five_tuple       = 20  # Lowest priority

enable_domain_allowlist = true

# --- 5-Tuple Rule Group Content ---

five_tuple_rg_capacity    = 100
five_tuple_rules_csv_path = "policy_config/dev/rule-fw1-us-east-1/five_tuple_rules.csv"

rules_csv_path = "policy_config/dev/rule-fw1-us-east-1/dev_rules.csv"

# --- Domain Rule Group (FQDN) Inputs ---

domain_rg_capacity = 100

stateful_rule_group_objects = [ ]

#stateful_rule_group_objects = [
	# {
	#   arn      = "arn:aws:network-firewall:us-east-1:359416636780:stateful-rulegroup/custom-rg-1"
	#   priority = 40
	# },
	# {
	#   arn      = "arn:aws:network-firewall:us-east-1:359416636780:stateful-rulegroup/custom-rg-2"
	#   priority = 50
	# }
#]

# Complex structured rules (used for testing)
# domain_rules = [
#  {
#     priority     = 10
#     action   = "PASS"
#     protocol     = "TCP"
#     source   = "ANY"
#     source_port = "ANY"
#     destination = "ANY" 
#     destination_port = "443"
#     direction = "FORWARD"
#     rule_options = [
#     {
#     keyword = "sid"
#     settings = ["2000001"]
#     },
#     {
#     keyword = "tls_sni"
#     settings = [".amazon.com"] 
# }
#     ]
#   },
#   {
#     priority     = 20
#     action   = "DROP"
#     protocol  = "TCP"
#     source  = "ANY"
#     source_port = "ANY"
#     destination = "ANY"
#     destination_port = "22"
#     direction   = "FORWARD"
#     rule_options    = [
#   {
#     keyword = "sid"
#     settings = ["2000002"]
#     }
#     ]
#   }
# ]