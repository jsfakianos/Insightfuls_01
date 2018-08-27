variable "regionB" {
    default = "region-B"
  }


module "vpc" {
  
  source    = "../../modules/vpc"
  name    = "DenseNet-vpc-${lookup(var.aws_region, var.regionB)}"

  providers = {
          aws = "aws.use1"
  }

  cidr                  = "10.0.0.0/16"

  azs                   = "${var.aws_availability_zones["us-east-1"]}"     
  private_subnets = [
                        "10.0.1.0/24", 
                        "10.0.2.0/24", 
                        "10.0.3.0/24",
                        "10.0.4.0/24", 
                        "10.0.5.0/24", 
                        "10.0.6.0/24"
                    ]
  public_subnets  = [
                        "10.0.7.0/24", 
                        "10.0.8.0/24", 
                        "10.0.9.0/24",
                        "10.0.10.0/24", 
                        "10.0.11.0/24", 
                        "10.0.12.0/24"
                    ]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "overridden-name-public"
  }

  tags = {
    Owner       = "${var.fellow_name}"
    Environment = "development"
  }

  vpc_tags = {
    Name = "DenseNet-vpc-${lookup(var.aws_region, var.regionB)}"
  }
}



module "autoscaling" {
  source  = "../../modules/asg"
  name                      = "DenseNet-asg-${lookup(var.aws_region, var.regionB)}"
  providers = {
    aws = "aws.use1"
  }

  ###################################
  # Define the launch configurations
  ###################################
    
  iam_instance_profile    = "${aws_iam_instance_profile.ecs_instance_profile.id}"  
  image_id                = "${lookup(var.amis, var.regionB)}"  
  instance_type           = "${var.instance_size}"  
  key_name                = "${lookup(var.keypair_name, var.regionB)}"

  security_groups         = ["${aws_security_group.allow_all_in_east.id}"]
  associate_public_ip_address = true


  root_block_device = [{
              volume_size = "100"
              volume_type = "standard"
          },]

  recreate_asg_when_lc_changes  = true
  #enable_dns_hostnames         = true

  ###########################################
  # Define the Autoscaling group parameters
  ###########################################
  
  vpc_zone_identifier       = "${module.vpc.public_subnets}"
  health_check_type         = "EC2"  
  
  target_group_arns         = ["${module.alb.target_group_arns}"]
  desired_capacity          = "${var.asg_desired}"
  min_size                  = "${var.asg_minimum}"
  max_size                  = "${var.asg_maximum}"
  


  tags_as_map {
    name                     = "insight-${var.regionB}-asg"
    Owner                    = "${var.fellow_name}"
    Environment              = "dev"
    Terraform                = "true" 
  } 

}




