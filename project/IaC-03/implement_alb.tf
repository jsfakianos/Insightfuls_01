module "alb" {
  source  			= "../../modules/alb"
  load_balancer_name            = "Insight-${var.aws_region}-alb"
  vpc_id                        = "${module.vpc.vpc_id}"
  subnets                       = ["${module.vpc.public_subnets}"]

  # logging should be enabled eventually, which will require log_bucket_name & log_location_prefix
  logging_enabled 		= "false"
  #log_bucket_name              = "logs-us-west-2-alb"
  #log_location_prefix          = "my-alb-logs"

  security_groups               = ["${aws_security_group.allow_all.id}"]
  

  http_tcp_listeners_count      = 2
  http_tcp_listeners            = "${list(	map(	"port", "80", 
							"protocol", "HTTP",
							"target_group_index", 0,),
                            			map(    "port", 8080,
			                                "protocol", "HTTP",
                        			        "target_group_index", 0,),
                            			)  }"


  target_groups                 = "${list(map(	"name", "foo2", 
						"backend_protocol", "HTTP", 
						"backend_port", "8080",
						"target_group_index", 0,))}"
  target_groups_count           = "1"

  tags                          = "${map("Environment", "test")}"

}
