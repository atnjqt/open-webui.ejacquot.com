terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "atn-developer"
}

resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = "chat-etienne-app"
  description = "Open Web-UI application for Etienne"
}

resource "aws_elastic_beanstalk_environment" "eb_app_env" {
  name                = "etienne-app-env"
  application         = aws_elastic_beanstalk_application.eb_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.9.1 running Docker"
  
  setting {
    namespace   = "aws:autoscaling:launchconfiguration"
    name        = "IamInstanceProfile"
    value       = "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace   = "aws:autoscaling:launchconfiguration"
    name        = "EC2KeyName"
    value       = "etienne-eb-key"  # Change this to your actual key pair name
  }
  setting {
    namespace   = "aws:autoscaling:launchconfiguration"
    name        = "DisableIMDSv1"
    value       = "true"
  }
  setting {
    namespace   = "aws:autoscaling:launchconfiguration"
    name        = "RootVolumeSize"
    value       = "40"
  }
  setting { 
    namespace   = "aws:autoscaling:asg"
    name        = "MinSize"
    value       = "1"
  }
  setting {
    namespace   = "aws:autoscaling:asg"
    name        = "MaxSize"
    value       = "1"
  }
  setting {
    namespace   = "aws:elasticbeanstalk:environment"
    name        = "EnvironmentType"
    value       = "LoadBalanced"
  }
  setting {
    namespace   = "aws:elasticbeanstalk:environment"
    name        = "LoadBalancerType"
    value       = "application"
  }

  setting {
    namespace   = "aws:ec2:instances"
    name        = "InstanceTypes"
    value       = "c6gd.medium"
  }

  setting {
    namespace   = "aws:elasticbeanstalk:environment:proxy"
    name        = "ProxyServer"
    value       = "nginx"
  }

  # HTTPS Listener Configuration
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = "arn:aws:acm:us-east-1:579747246975:certificate/af4c521f-09a5-47ef-b931-4836e67cd03a"
  }

  # Keep HTTP listener enabled for redirect
  setting {
    namespace = "aws:elbv2:listener:80"
    name      = "ListenerEnabled"
    value     = "true"
  }
}

# Reference the existing hosted zone for ejacquot.com
data "aws_route53_zone" "ejacquot" {
  name         = "ejacquot.com."
  private_zone = false
}

resource "aws_route53_record" "eb_dns" {
  zone_id = data.aws_route53_zone.ejacquot.id
  name    = "open-webui.ejacquot.com"
  type    = "A"

  alias {
    name                   = aws_elastic_beanstalk_environment.eb_app_env.cname
    zone_id                = "Z117KPS5GTRQ2G"  # Elastic Beanstalk zone ID for us-east-1
    evaluate_target_health = false
  }
}