# Create a security group for the ALB
resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg"
  vpc_id      = "${aws_vpc.example_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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

