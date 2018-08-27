


########################################################################
#
#                  ROUTE 53 RECORD
#
# https://www.terraform.io/docs/providers/aws/r/route53_record.html
########################################################################

resource "aws_route53_record" "www-sfaki" {
  zone_id 				= "${aws_route53_zone.sfaki.zone_id}"
  name    				= "www.sfaki.com"
  type    				= "A"
  ttl     				= "30"
  records 				= [
  							"${data.dns_a_record_set.west-alb-ip.addrs}", 
  							"${data.dns_a_record_set.east-alb-ip.addrs}"
  						]

  #records 				= ["${module.west-alb.dns_name}","${module.alb.dns_name}",]
}





########################################################################
#
#                  GET DNS NAME A ADDRESSES
#
# https://github.com/hashicorp/terraform/issues/18191
# https://www.terraform.io/docs/providers/dns/d/dns_a_record_set.html
########################################################################


data "dns_a_record_set" "west-alb-ip" {
  host  = "${module.west-alb.dns_name}"
}

data "dns_a_record_set" "east-alb-ip" {
  host  = "${module.alb.dns_name}"
}





########################################################################
#
#                  ROUTE 53 ZONE
#
#https://www.terraform.io/docs/providers/aws/d/route53_zone.html
########################################################################

resource "aws_route53_zone" "sfaki" {
  name         			= "sfaki.com"
}




