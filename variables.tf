variable "name" {
  type        = string
  default     = "lucid-code-test"
  description = "Root name for resources in this project"
}

variable "vpc_cidr" {
  default     = "10.1.0.0/16"
  type        = string
  description = "VPC cidr block"
}

variable "newbits" {
  default     = 8
  type        = number
  description = "How many bits to extend the VPC cidr block by for each subnet"
}

variable "public_subnet_count" {
  default     = 3
  type        = number
  description = "How many subnets to create"
}

variable "private_subnet_count" {
  default     = 3
  type        = number
  description = "How many private subnets to create"
}

variable "aws_lb" {
  type        = number
  default     = 1
  description = "load balancer"
}

variable "aws_lb_listener" {
  type        = number
  default       = 1
  description = "number of listners"
}

variable "ec2_sg" {
  type        = number
  default     = 1
  description = "ec2 security group"
}

variable "ec2_instance_id" {
  type        = number
  default     = 2
  description = "ec2 instance id"
}

variable "alb_sg" {
  type        = number
  default     = 1
  description = "alb security group"
}
