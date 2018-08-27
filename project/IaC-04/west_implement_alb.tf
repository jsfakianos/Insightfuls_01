


  ################################################################
  #      define the application load balancer
  # 
  # important is the listening port and the backend port
  # https://github.com/terraform-aws-modules/terraform-aws-alb
  # https://www.terraform.io/docs/providers/aws/r/lb.html
  # https://www.terraform.io/docs/providers/aws/r/lb_listener.html
  ################################################################


module "west-alb" {
  source  			                = "../../modules/alb"
  providers = {
        aws = "aws.usw2"
  }
  load_balancer_name            = "DenseNet-lb-${lookup(var.aws_region, var.region)}"
  vpc_id                        = "${module.west-vpc.vpc_id}"
  subnets                       = ["${module.west-vpc.public_subnets}"]

  # logging should be enabled eventually, which will require log_bucket_name & log_location_prefix
  logging_enabled 		          = "false"
  #log_bucket_name              = "logs-us-west-2-alb"
  #log_location_prefix          = "my-alb-logs"

  security_groups               = ["${aws_security_group.allow_all_in_west.id}"]
  

  http_tcp_listeners_count      = 1
  http_tcp_listeners            = "${list(	map(	 "port", "80", 
							                                     "protocol", "HTTP",
							                                     "target_group_index", 0,))
                                    }"


  target_groups                 = "${list(map(	"name", "DenseNet-west-alb-group", 
						                                    "backend_protocol", "HTTP", 
						                                    "backend_port", "5000",
						                                    "target_group_index", 0,))}"
  target_groups_count           = "1"

  tags                          = "${map("Environment", "test")}"

}
