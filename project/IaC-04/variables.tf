

variable "asg_minimum" {
  description = "Auto-scaling group minimum size."
  default     = "2"
}

variable "asg_maximum" {
  description = "Auto-scaling group maximum size."
  default     = "3"
}

variable "asg_desired" {
  description = "Auto-scaling group desired size."
  default     = "2"
}

variable "instance_size" {
  description = "AWS Instance size for the machine."
  default     = "t2.large"
}

variable "fellow_name" {
  description = "The name that will be tagged on your resources."
	default = "jsfa"
}



variable "aws_region" {
  description         = "AWS region to launch servers."
  type                = "map"
  default             = {
        "region-A"          = "us-west-2"
        "region-B"          = "us-east-1"
  }
}

variable "keypair_name" {
  type                = "map"
  default             = {
        "region-A"         = "InsightAug21"
        "region-B"         = "eastInsightAug26keypair"
        
  }
}

variable "amis" {
  type                = "map"
  default             = {
        "region-A"         = "ami-088e41413298030dd"
        "region-B"         = "ami-0076e3a833327e4f2"
        
  }
}

variable "cluster_name" {
  description = "The name for your instances in your cluster" 
  type                = "map"
	default             = {
        "region-A"         = "DenseNet-cluster-us-west-2"
        "region-B"         = "DenseNet-cluster-us-east-1"
  }
}

variable "server_port" {
  description = "Port for the server for http requests"
  default = 8080
}


variable "aws_availability_zones" {
  type                = "map"
  default = {

    "us-east-1" = [
                        "us-east-1a", 
                        "us-east-1b", 
                        "us-east-1f", 
                        "us-east-1c", 
                        "us-east-1d", 
                        "us-east-1e"
    ],

    "us-east-2" = [
                        "us-east-2a",
                        "us-east-2b",
                        "us-east-2c",
    ],

    "us-west-1" = [
                        "us-west-1a",
                        "us-west-1b",
                        "us-west-1c",
    ],

    "us-west-2" = [
                        "us-west-2a",
                        "us-west-2b",
                        "us-west-2c",
    ]

  } 
}




