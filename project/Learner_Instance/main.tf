provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "learner_instance" {
  name = "terraform-learner-instance"
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



resource "aws_instance" "example" {
  ami = "ami-0012bb000f57b99cb"    		#"ami-18693660"
  instance_type = "t2.large"
  key_name = "InsightAug13"
  vpc_security_group_ids = ["${aws_security_group.learner_instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags {
    Name = "flask-instance-single"
  }
}


output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}
output "id" {
  value = "${aws_instance.example.id}"
}
output "dns" {
  value = "${aws_instance.example.public_dns}"
}

