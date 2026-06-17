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
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = var.app_name
  description = var.app_description
}

resource "aws_elastic_beanstalk_environment" "eb_app_env" {
  name                = var.environment_name
  application         = aws_elastic_beanstalk_application.eb_app.name
  solution_stack_name = var.solution_stack_name
  setting {
    namespace   = "aws:autoscaling:launchconfiguration"
    name        = "IamInstanceProfile"
    value       = var.instance_profile
  }
  #setting {
  #  namespace   = "aws:autoscaling:launchconfiguration"
  #  name        = "EC2KeyName"
  #  value       = "etienne-eb-key"  # Change this to your actual key pair name
  #}
  setting {
    namespace   = "aws:autoscaling:launchconfiguration"
    name        = "DisableIMDSv1"
    value       = "true"
  }
  setting {
    namespace   = "aws:autoscaling:launchconfiguration"
    name        = "RootVolumeSize"
    value       = var.root_volume_size
  }
  setting { 
    namespace   = "aws:autoscaling:asg"
    name        = "MinSize"
    value       = var.min_instances
  }
  setting {
    namespace   = "aws:autoscaling:asg"
    name        = "MaxSize"
    value       = var.max_instances
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
    value       = var.instance_type
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
    value     = var.ssl_certificate_arn
  }

  # Keep HTTP listener enabled for redirect
  setting {
    namespace = "aws:elbv2:listener:80"
    name      = "ListenerEnabled"
    value     = "true"
  }
}

# Reference the existing hosted zone for ejacquot.com
data "aws_route53_zone" "main" {
  name         = var.hosted_zone_name
  private_zone = false
}



resource "aws_route53_record" "eb_dns" {
  zone_id = data.aws_route53_zone.main.id
  name    = "${var.subdomain}.${trimsuffix(var.hosted_zone_name, ".")}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elastic_beanstalk_environment.eb_app_env.cname]
}