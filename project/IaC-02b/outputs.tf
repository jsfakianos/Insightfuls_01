




# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc.vpc_id}"
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${module.vpc.private_subnets}"]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = ["${module.vpc.public_subnets}"]
}

# NAT gateways
output "nat_public_ips" {
  description 	= "List of public Elastic IPs created for AWS NAT Gateway"
  value       	= ["${module.vpc.nat_public_ips}"]
}


#output "instance_ips" {
#  description = "List of public ip addresses for EC2 instances."
#  value		= ["${module.autoscaling.}"]
#}



#output "application load balancer dns_name" {
#  description = "The DNS name of the load balancer."
#  value       = "${module.alb.dns_name}"
#}