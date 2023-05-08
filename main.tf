terraform {
  required_version = "~>1.4.6"

    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
}

# Create a security group for the ALB (Application load balancer)
resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.main.arn
    type             = "forward"
  }
}
#security group for rds is configured below, allowing it to recieve data on port 3306
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.ec2_sg.id}"]
  }
}

# Create a security group for the autoscaling group
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"

  vpc_id = aws_vpc.main.id

  # Allow inbound traffic on port 80 from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound traffic from the RDS instance
  ingress {
    from_port   = 0
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.rds_sg.id]
  }
}


resource "aws_security_group_rule" "rds_sg_egress" {
  security_group_id = "${aws_security_group.rds_sg.id}"

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "my-rds-instance"
  username             = "admin"
  password             = "admin123"
  skip_final_snapshot  = true
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id,
  ]
}
# resource "aws_launch_configuration" "ec2_lc" {
#   name_prefix      = "ec2-lc-"
#   image_id         = var.instance_ami
#   instance_type    = "t2.nano"
#   key_name         = var.instance_keypair
#   security_groups  = [aws_security_group.web_sg.id]
#   user_data        = filebase64("userdata.sh")
#   lifecycle {
#     create_before_destroy = true
#   }
# }
resource "aws_autoscaling_group" "asg" {
  name_prefix                 = "my-asg"
  desired_capacity            = 2
  health_check_grace_period   = 300
  health_check_type           = "EC2"
  vpc_zone_identifier         = ["${aws_subnet.private.*.id}"]
  launch_configuration        = aws_launch_configuration.ec2_lc.name
  # add launch template & security group and link to target group arn

  tag {
    key                 = "Name"
    value               = "my-asg"
    propagate_at_launch = true
  }
}




