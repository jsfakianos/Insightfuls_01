provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}



######################################################
# 	apply resource for IAM role
######################################################

resource "aws_iam_role" "ecs-instance-role" {
	name 				= "ecs-instance-role"
	path 				= "/"
	assume_role_policy 		= <<EOF
{"Version": "2012-10-17",
    "Statement": [{
	"Effect": "Allow",
	"Principal": {
		"Service": "ec2.amazonaws.com"
		     },
		"Action": "sts:AssumeRole"
		     }
                 ]
}EOF
}


resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "${aws_iam_role.ecs-instance-role.name}"
}


resource "aws_iam_instance_profile" "ecs_instance_profile" {
    	name 		= "ecs_instance_profile"
	path		= "/"
    	role 		= "${aws_iam_role.ecs-instance-role.id}"
}



######################################################
# 	instance
######################################################

resource "aws_instance" "application_server" {
  iam_instance_profile = "${aws_iam_instance_profile.ecs_instance_profile.id}"  
  ami = "ami-088e41413298030dd"  
  instance_type = "t2.large"
  key_name = "InsightAug21"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags {
    Name = "DenseNet_classification_server"
  }
}


output "public_ip" {
  value = "${aws_instance.application_server.public_ip}"
}
output "id" {
  value = "${aws_instance.application_server.id}"
}
output "dns" {
  value = "${aws_instance.application_server.public_dns}"
}

