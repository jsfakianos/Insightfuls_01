/* 

Terraform file to define which variables are used

This is NOT where you set the variables. Instead, they should be 
set at the command line, with .tfvars files, or with environment variables

 */

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "keypair_name" {
	description = "The name of your pre-made key-pair in Amazon." 
	default = "InsightAug13"
} 

variable "fellow_name" {
  description = "The name that will be tagged on your resources."
	default = "jsfa"
}

variable "amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-0e32dc18"
    "us-west-2" = "ami-088e41413298030dd"    #"ami-ba602bc2"
  }
}

variable "cluster_name" {
	description = "The name for your instances in your cluster" 
	default 	= "insight-cluster-us-west-2"
}

variable "server_port" {
  description = "Port for the server for http requests"
  default = 8080
}

