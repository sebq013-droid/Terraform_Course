# --------------------------------------------------
# AMI Bitnami Tomcat
# --------------------------------------------------
data "aws_ami" "tomcat" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }
								  
					
   

									 
 

  owners = ["979382823631"]
				
}

# --------------------------------------------------
# VPC
# --------------------------------------------------
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "blog-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-west-2a", "us-west-2b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = false

  tags = {
						
    Environment = "dev"
  }
}

# --------------------------------------------------
# SECURITY GROUP - ALB
# --------------------------------------------------
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"

  name   = "alb-sg"
  vpc_id = module.vpc.vpc_id
				   
									   
  
			   
			  
			  

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]
								   
}

# --------------------------------------------------
# SECURITY GROUP - EC2
# --------------------------------------------------
module "ec2_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"

  name   = "ec2-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "http-8080-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]

  egress_rules = ["all-all"]
}

# --------------------------------------------------
# APPLICATION LOAD BALANCER
# --------------------------------------------------
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "blog-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

				  
  security_groups = [module.alb_sg.security_group_id]

  target_groups = {
    blog = {
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "instance"
      health_check = {
        path = "/"
      }
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
   
  

		  
					   
						   
   
 

				  
													  
				   

				 
								 

														
									 

								  
									
 

    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.acm_certificate_arn

      forward = {
        target_group_key = "blog"
      }
    }
  }
}

# --------------------------------------------------
# AUTO SCALING GROUP
# --------------------------------------------------
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "9.0.2"

  name = "blog-asg"
 

  min_size         = 1
  max_size         = 2
  desired_capacity = 1
				 
					
							 

  vpc_zone_identifier = module.vpc.public_subnets
  security_groups     = [module.ec2_sg.security_group_id]

  image_id      = data.aws_ami.tomcat.id
  instance_type = "t3.micro"
				  
				  
					 
							 

  target_group_arns = [
    module.alb.target_groups["blog"].arn
  ]
}