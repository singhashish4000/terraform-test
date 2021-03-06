variable "whitelist" {
  type = list(string)
  default = ["0.0.0.0/0"]
}
variable "web_image_id" {
  type = string
  default = "ami-479b843e"
}
variable "web_instance_type" {
  type = string
  default = "t2.nano"
}
variable "web_desired_capacity" {
  type = number
  default = 1
}
variable "web_max_size" {
  type = number
  default = 1
}
variable "web_min_size" {
  type = number
  default = 1
}

provider "aws" {
  profile =  "default"
  region  = "us-west-2"
}

resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "tf-course-2020821"
  acl    = "private"    
  tags   = {
    "Teraform" : "true"
  }  
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-west-2a"
  tags = {
    "Teraform" : "true"
  }  
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-west-2b"
  tags = {
    "Teraform" : "true"
  }  
}

resource "aws_security_group" "prod_web" {
  name        = "prod_web"
  description = "Allow standard http and https ports inbound and everything outbound" 

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.whitelist
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.whitelist
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.whitelist
  }  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.whitelist
  }

  tags = {
    "Teraform" : "true"
  }
}

module "web_app" {
  source = "./modules/web_app"

  web_image_id         =  var.web_image_id
  web_instance_type    =  var.web_instance_type
  web_desired_capacity =  var.web_desired_capacity
  web_max_size         =  var.web_max_size
  web_min_size         =  var.web_min_size
  subnets              =  [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  security_groups      =  [aws_security_group.prod_web.id]
  web_app              =  "prod"
}

# resource "aws_instance" "prod_web" {
#   count = 2

#   ami           = "ami-01cfa0ce6fe1024f8"
#   instance_type = "t2.nano"
#   key_name      = "Terraform-Course"

#   vpc_security_group_ids = [
#     aws_security_group.prod_web.id 
#   ]

#   tags = {
#     "Teraform" : "true"
#   }
# }

# resource "aws_eip_association" "prod_web" {
#   instance_id   = aws_instance.prod_web.0.id
#   allocation_id = aws_eip.prod_web.id
# }

# resource "aws_eip" "prod_web" {
#   tags = {
#     "Teraform" : "true"
#   }  
# }

