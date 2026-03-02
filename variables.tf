variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.micro"
}

variable "ami_filter" {
  description = "Name filter and owner for AMI"
  type   = object  ({
  name   = string
  powner = string
})

  default  = {
    name   = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    powner  = "979382823631" # Bitnami
 }
}

variable "environment" {
  description = "Deployment environment"
  type = object ({
  name           = string
  network_prefix = string
})
default = {
name             = "dev"
network_prefix   = "10.0"
  } 
}

variable "min_size"{
  description = "minimum number of instances in the ASG"
  default = 1
}

variable "max_size"{
  description = "minimum number of instances in the ASG"
  default = 2
}
 
