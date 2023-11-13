provider "aws" {
  alias = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "us-east-1"
}

###
#first vpc:VPC in US-east-1
###
#
#

resource "aws_vpc" "deployment6-vpc-east" {
  provider = aws.us-east-1
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "deployment6-vpc-east"
  }
}

output "east_vpc_id" {
  value = aws_vpc.deployment6-vpc-east.id
}


#create subnet A: VPC in US-east-1
resource "aws_subnet" "dep6publicSubnetA" {
  provider = aws.us-east-1
  vpc_id     = aws_vpc.deployment6-vpc-east.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "dep6publicSubnetA"
    vpc : "deployment6-vpc-east"
    az : "us-east-1a"
  }
}

output "pub_subneta_id" {
  value = aws_subnet.dep6publicSubnetA.id
}


#create subnet B: VPC in US-east-1
resource "aws_subnet" "dep6publicSubnetB" {
  provider = aws.us-east-1
  vpc_id     = aws_vpc.deployment6-vpc-east.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "dep6publicSubnetB"
    vpc : "deployment6-vpc-east"
    az : "us-east-1b"
  }
}

output "pub_subnetb_id" {
  value = aws_subnet.dep6publicSubnetB.id
}


#create route table:VPC in US-east-1
resource "aws_route_table" "deployment6-rt-east" {
  provider = aws.us-east-1
  vpc_id = aws_vpc.deployment6-vpc-east.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.deployment6_igw.id
  }

  tags = {
    Name : "deployment6-rt"
    vpc : "deployment6-vpc-east"
  }
}

#create route table association: VPC in US-east-1
resource "aws_route_table_association" "public_a" {
  provider = aws.us-east-1
  subnet_id      = aws_subnet.dep6publicSubnetA.id
  route_table_id = aws_route_table.deployment6-rt-east.id
}

resource "aws_route_table_association" "public_b" {
  provider = aws.us-east-1
  subnet_id      = aws_subnet.dep6publicSubnetB.id
  route_table_id = aws_route_table.deployment6-rt-east.id
}

#create internet gateway: VPC in US-east-1
resource "aws_internet_gateway" "deployment6_igw" {
  provider = aws.us-east-1
  vpc_id = aws_vpc.deployment6-vpc-east.id

  // igw config

  tags = {
    Name = "deployment6_igw"

  }

}

 #create first instance:VPC in US-east-1
resource "aws_instance" "D6appServer01-east" {
  provider = aws.us-east-1
  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG.id]
  subnet_id = aws_subnet.dep6publicSubnetA.id
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("software.sh")}"

  tags = {
    Name : "D6appServer01-east"
    vpc : "deployment6-vpc-east"
    az : "us-east-1a"
  }
}


 #create second instance:VPC in US-east-1
resource "aws_instance" "D6appServer02-east" {
  provider = aws.us-east-1
  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG.id]
  subnet_id = aws_subnet.dep6publicSubnetB.id 
  associate_public_ip_address = true
  key_name = var.key_name 
   
  user_data = "${file("software.sh")}"

  tags = {
    Name : "D6appServer01-east"
    vpc : "deployment6-vpc-east"
    az : "us-east-1b"
  }
}  


output "applicationServer01-east_ip" {
  value = aws_instance.D6appServer01-east.public_ip
}

output "applicationServer02-east_ip" {
  value = aws_instance.D6appServer02-east.public_ip
}

#
#
#
#
#configurations for second vpc
#second vpc:VPC in US-west-2
#
provider "aws" {
  alias = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "us-west-2"
}

#
#
resource "aws_vpc" "deployment6-vpc-west" {
  provider = aws.us-west-2
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "deployment6-vpc-west"
  }
}

output "west_vpc_id" {
  value = aws_vpc.deployment6-vpc-west.id
}


#create subnet C: VPC in US-west-2
resource "aws_subnet" "dep6publicSubnetC" {
  provider = aws.us-west-2
  vpc_id     = aws_vpc.deployment6-vpc-west.id
  availability_zone = "us-west-2a"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true


  tags = {
    Name = "dep6publicSubnetC"
    vpc : "deployment6-vpc-west"
    az : "us-west-2a"
  }
}

output "pub_subnetc_id" {
  value = aws_subnet.dep6publicSubnetC.id
}


#create subnet D: VPC in US-west-2
resource "aws_subnet" "dep6publicSubnetD" {
  provider = aws.us-west-2
  vpc_id     = aws_vpc.deployment6-vpc-west.id
  availability_zone = "us-west-2b"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "dep6publicSubnetD"
    vpc : "deployment6-vpc-west"
    az : "us-west-2b"
  }
}

output "pub_subnetd_id" {
  value = aws_subnet.dep6publicSubnetD.id
}

#create route table:VPC in US-west-2
resource "aws_route_table" "deployment6-rt-west" {
  provider = aws.us-west-2
  vpc_id = aws_vpc.deployment6-vpc-west.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.deployment6_igw-west.id
  }

  tags = {
    Name : "deployment6-rt-west"
    vpc : "deployment6-vpc-west"
  }
}

#create route table association: VPC in US-west-2
resource "aws_route_table_association" "public_c" {
  provider = aws.us-west-2
  subnet_id      = aws_subnet.dep6publicSubnetC.id
  route_table_id = aws_route_table.deployment6-rt-west.id
}

resource "aws_route_table_association" "public_d" {
  provider = aws.us-west-2
  subnet_id      = aws_subnet.dep6publicSubnetD.id
  route_table_id = aws_route_table.deployment6-rt-west.id
}

#create internet gateway: VPC in US-west-2
resource "aws_internet_gateway" "deployment6_igw-west" {
  provider = aws.us-west-2
  vpc_id = aws_vpc.deployment6-vpc-west.id

  // igw config

  tags = {
    Name = "deployment6_igw-west"

  }

}


 #create first instance:VPC in US-west-2
resource "aws_instance" "D6appServer01-west" {
  provider = aws.us-west-2
  ami = "ami-0efcece6bed30fd98"
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG-west.id]
  subnet_id = aws_subnet.dep6publicSubnetC.id
  associate_public_ip_address = true
  key_name = "us-west-2"

  user_data = "${file("software.sh")}"

  tags = {
    Name : "D6appServer01-west"
    vpc : "deployment6-vpc-west"
    az : "us-west-2a"
  }
}


 #create second instance:VPC in US-west-2
resource "aws_instance" "D6appServer02-west" {
  provider = aws.us-west-2
  ami = "ami-0cd5f46e93e42a496"
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG-west.id]
  subnet_id = aws_subnet.dep6publicSubnetD.id 
  associate_public_ip_address = true
  key_name = "us-west-2" 
   
  user_data = "${file("software.sh")}"

  tags = {
    Name : "D6appServer02-west"
    vpc : "deployment6-vpc-west"
    az : "us-west-2b"
  }
}  


output "applicationServer01-west_ip" {
  value = aws_instance.D6appServer01-west.public_ip
}

output "applicationServer02-west_ip" {
  value = aws_instance.D6appServer02-west.public_ip
}


# create security group

resource "aws_security_group" "SSH-HttpAcessSG" {
  provider = aws.us-east-1
  name        = "SSH-HttpAcessSG"
  description = "open ssh traffic"
  vpc_id = aws_vpc.deployment6-vpc-east.id

  ingress {
     from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : "SSH-HttpAcessSG"
    "Terraform" : "true"
  }

}

# create security group: VPC in US-west-2

resource "aws_security_group" "SSH-HttpAcessSG-west" {
  provider = aws.us-west-2
  name        = "SSH-HttpAcessSG-west"
  description = "open ssh traffic"
  vpc_id = aws_vpc.deployment6-vpc-west.id

  ingress {
     from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : "SSH-HttpAcessSG-west"
    "Terraform" : "true"
  }

}



##################################################################################



#############################ALB configs for us-east-1 deployment###################################
#Target Group for port 8000 needed for my application
resource "aws_lb_target_group" "east_target-lb" {
  provider = aws.us-east-1
  name        = "dep6target-east"
  port        = 8000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.deployment6-vpc-east.id

  health_check {
    enabled = true
    path    = "/health"
  }

  depends_on = [aws_alb.Dep6-alb-east]
}


#Application Load Balancer
resource "aws_alb" "Dep6-alb-east" {
  provider = aws.us-east-1
  name               = "dep6lb-east"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.dep6publicSubnetA.id,
    aws_subnet.dep6publicSubnetB.id
  ]

  security_groups = [
    aws_security_group.d6alb_sg_east.id
  ]

  depends_on = [aws_internet_gateway.deployment6_igw]
}


#############alb_listener##################

resource "aws_alb_listener" "dep6_alb_listener-east" {
  provider = aws.us-east-1
  load_balancer_arn = aws_alb.Dep6-alb-east.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.east_target-lb.arn
  }
}

output "alb_url" {
  value = "http://${aws_alb.Dep6-alb-east.dns_name}"
}

#######################alb_sg#########################
resource "aws_security_group" "d6alb_sg_east" {
  provider = aws.us-east-1
  name        = "d6alb_sg_east"
  description = "HTTP access for us-east-1 ALB"
  vpc_id      = aws_vpc.deployment6-vpc-east.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


###############################ALB configs for us-west-2 deployment####################################
#Target Group for port 8000 needed for my application
resource "aws_lb_target_group" "west_target-lb" {
  provider = aws.us-west-2
  name        = "dep6target-west"
  port        = 8000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.deployment6-vpc-west.id

  health_check {
    enabled = true
    path    = "/health"
  }

  depends_on = [aws_alb.Dep6-alb-west]
}


#Application Load Balancer
resource "aws_alb" "Dep6-alb-west" {
  provider = aws.us-west-2
  name               = "dep6lb-west"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.dep6publicSubnetC.id,
    aws_subnet.dep6publicSubnetD.id
  ]

  security_groups = [
    aws_security_group.d6alb_sg_west.id
  ]

  depends_on = [aws_internet_gateway.deployment6_igw-west]
}


#############alb_listener##################

resource "aws_alb_listener" "dep6_alb_listener-west" {
  provider = aws.us-west-2
  load_balancer_arn = aws_alb.Dep6-alb-west.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.west_target-lb.arn
  }
}

output "west_alb_url" {
  value = "http://${aws_alb.Dep6-alb-west.dns_name}"
}

#######################alb_sg#########################
resource "aws_security_group" "d6alb_sg_west" {
  provider = aws.us-west-2
  name        = "d6alb_sg_west"
  description = "HTTP access for us-west-2 ALB"
  vpc_id      = aws_vpc.deployment6-vpc-west.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
