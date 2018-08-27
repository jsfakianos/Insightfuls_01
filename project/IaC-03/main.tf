provider "aws" {
  region   = "${var.aws_region}"
  version  = "~> 1.14"
}



module "vpc" {
  source  	= "../../modules/vpc"
  name 		= "Insight-${var.aws_region}-vpc"

  cidr 		= "10.0.0.0/16"

  azs		  = ["${data.aws_availability_zones.available.names}"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "overriden-name-public"
  }

  tags = {
    Owner       = "${var.fellow_name}"
    Environment = "mgmt"
  }

  vpc_tags = {
    Name = "Insight-${var.aws_region}-vpc"
  }
}



module "autoscaling" {
  source  = "../../modules/asg"
  #version = "2.7.0"

  ###################################
  # Define the launch configurations
  ###################################

  image_id			= "${lookup(var.amis, var.aws_region)}"  
  instance_type   		= "t2.micro"  
  key_name        		= "${var.keypair_name}"
  security_groups		= ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address	= true




  root_block_device = [{
		          volume_size = "100"
		          volume_type = "standard"
	    		},]

  recreate_asg_when_lc_changes 	= true
  #enable_dns_hostnames 		= true

  ###########################################
  # Define the Autoscaling group parameters
  ###########################################
  name 				= "Insight-${var.aws_region}-asg"
  vpc_zone_identifier 		= "${module.vpc.public_subnets}"
  health_check_type		= "EC2"  
  
  #target_group_arns = ["${module.alb.target_group_arns}"]
  desired_capacity		= 2
  min_size			= 2 
  max_size			= 3
  


  tags_as_map {
    name	= "insight-${var.aws_region}-asg"
    Owner       = "${var.fellow_name}"
    Environment = "dev"
    Terraform   = "true" 
  } 

}




