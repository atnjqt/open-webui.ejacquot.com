variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
}

variable "app_name" {
  description = "Elastic Beanstalk application name"
  type        = string
}

variable "app_description" {
  description = "Elastic Beanstalk application description"
  type        = string
  default     = "Open Web-UI application"
}

variable "environment_name" {
  description = "Elastic Beanstalk environment name"
  type        = string
}

variable "solution_stack_name" {
  description = "Elastic Beanstalk solution stack"
  type        = string
  default     = "64bit Amazon Linux 2023 v4.13.2 running Docker"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "c6gd.medium"
}

variable "instance_profile" {
  description = "IAM instance profile for EC2 instances"
  type        = string
  default     = "aws-elasticbeanstalk-ec2-role"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = string
  default     = "40"
}

variable "min_instances" {
  description = "Minimum number of instances in ASG"
  type        = string
  default     = "1"
}

variable "max_instances" {
  description = "Maximum number of instances in ASG"
  type        = string
  default     = "1"
}

variable "ssl_certificate_arn" {
  description = "ARN of the ACM SSL certificate for HTTPS"
  type        = string
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone name (with trailing dot)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for the app (e.g. open-webui)"
  type        = string
  default     = "open-webui"
}
