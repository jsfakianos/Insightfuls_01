
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


