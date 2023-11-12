provider "aws" {
  alias = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
  region = "us-east-1"
}

resource "aws_vpc" "default-vpc-east" {
  provider = aws
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "default-vpc-east"
  }
}


#create route table:VPC in US-east-1
resource "aws_route_table" "default-rt" {
  provider = aws
  vpc_id = aws_vpc.default-vpc-east.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default-vpc-east_igw.id
  }

  tags = {
    Name : "default-rt"
    vpc : "default-vpc-east"
  }
}

#create route table association: VPC in US-east-1
resource "aws_route_table_association" "public_defa" {
  provider = aws
  subnet_id      = aws_subnet.defpublicSubnetA.id
  route_table_id = aws_route_table.default-rt.id
}

resource "aws_route_table_association" "public_defb" {
  provider = aws
  subnet_id      = aws_subnet.defpublicSubnetB.id
  route_table_id = aws_route_table.default-rt.id
}

#create subnet A: VPC default
resource "aws_subnet" "defpublicSubnetA" {
  provider = aws
  vpc_id     = aws_vpc.default-vpc-east.id
  availability_zone = "${var.regionvpc1}a"
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "defpublicSubnetA"
    vpc : "default-vpc-east"
    az : "${var.regionvpc1}a"
  }
}

output "defpub_subneta_id" {
  value = aws_subnet.defpublicSubnetA.id
}


#create subnet B: VPC default
resource "aws_subnet" "defpublicSubnetB" {
  provider = aws
  vpc_id     = aws_vpc.default-vpc-east.id
  availability_zone = "${var.regionvpc1}b"
  cidr_block = "10.0.5.0/24"
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "defpublicSubnetB"
    vpc : "default-vpc-east"
    az : "${var.regionvpc1}b"
  }
}

output "defpub_subnetb_id" {
  value = aws_subnet.defpublicSubnetB.id
}

#create first instance:default-vpc with jenkins and deadsnakes
resource "aws_instance" "dep6jenkinsserver" {
  provider = aws
  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG-def.id]
  subnet_id = aws_subnet.defpublicSubnetA.id
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("jenkins.sh")}"

  tags = {
    Name : "dep6jenkinsserver"
    vpc : "default-vpc-east"
    az : "${var.regiondefvpc}a"
  }
}


 #create second instance:default-vpc with Terraform and java environment
resource "aws_instance" "dep6jenkinsagentsever" {
  provider = aws
  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG-def.id]
  subnet_id = aws_subnet.defpublicSubnetA.id 
  associate_public_ip_address = true
  key_name = var.key_name 
   
  user_data = "${file("java.sh")}"

  tags = {
    Name : "dep6jenkinsagentsever"
    vpc : "default-vpc-east"
    az : "${var.regiondefvpc}b"
  }
}  


#create internet gateway: default vpc
resource "aws_internet_gateway" "default-vpc-east_igw" {
  provider = aws
  vpc_id = aws_vpc.default-vpc-east.id

  // igw config

  tags = {
    Name = "default-vpc-east_igw"

  }

}

# create security group: default vpc

resource "aws_security_group" "SSH-HttpAcessSG-def" {
  provider = aws
  name        = "SSH-HttpAcessSG-def"
  description = "open ssh traffic"
  vpc_id = aws_vpc.default-vpc-east.id

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

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 8080
    to_port = 8080
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
    "Name" : "SSH-HttpAcessSG-def"
    "Terraform" : "true"
  }

}

output "default_vpc_id" {
  value = aws_vpc.default-vpc-east.id
}

output "dep6jenkinsserver_ip" {
  value = aws_instance.dep6jenkinsserver.public_ip
}

output "dep6jenkinsagentsever_ip" {
  value = aws_instance.dep6jenkinsagentsever.public_ip
}
#
#
#
#
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
###
#first vpc:VPC in US-east-1
###
#
#

resource "aws_vpc" "deployment6-vpc-east" {
  provider = aws.us-east-1
<<<<<<< HEAD
  cidr_block       = "10.0.0.0/16"
=======
  cidr_block       = var.vpceast_cidr
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
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
<<<<<<< HEAD
  availability_zone = "us-east-1a"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "dep6publicSubnetA"
    vpc : "deployment6-vpc-east"
    az : "us-east-1a"
=======
  availability_zone = "${var.regionvpc1}a"
  cidr_block = var.dep6publicSubnetA_cidr
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "dep6publicSubnetA"
    vpc : "deployment6-vpc-east"
    az : "${var.regionvpc1}a"
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  }
}

output "pub_subneta_id" {
  value = aws_subnet.dep6publicSubnetA.id
}


#create subnet B: VPC in US-east-1
resource "aws_subnet" "dep6publicSubnetB" {
  provider = aws.us-east-1
  vpc_id     = aws_vpc.deployment6-vpc-east.id
<<<<<<< HEAD
  availability_zone = "us-east-1b"
  cidr_block = "10.0.1.0/24"
=======
  availability_zone = "${var.regionvpc1}b"
  cidr_block = var.dep6publicSubnetB_cidr
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "dep6publicSubnetB"
    vpc : "deployment6-vpc-east"
<<<<<<< HEAD
    az : "us-east-1b"
=======
    az : "${var.regionvpc1}b"
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  }
}

output "pub_subnetb_id" {
  value = aws_subnet.dep6publicSubnetB.id
}


#create route table:VPC in US-east-1
<<<<<<< HEAD
resource "aws_route_table" "deployment6-rt-east" {
=======
resource "aws_route_table" "deployment6-rt" {
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
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
<<<<<<< HEAD
  route_table_id = aws_route_table.deployment6-rt-east.id
=======
  route_table_id = aws_route_table.deployment6-rt.id
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
}

resource "aws_route_table_association" "public_b" {
  provider = aws.us-east-1
  subnet_id      = aws_subnet.dep6publicSubnetB.id
<<<<<<< HEAD
  route_table_id = aws_route_table.deployment6-rt-east.id
=======
  route_table_id = aws_route_table.deployment6-rt.id
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
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
<<<<<<< HEAD
resource "aws_instance" "D6appServer01-east" {
=======
resource "aws_instance" "applicationServer01-east" {
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  provider = aws.us-east-1
  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG.id]
  subnet_id = aws_subnet.dep6publicSubnetA.id
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("software.sh")}"

  tags = {
<<<<<<< HEAD
    Name : "D6appServer01-east"
    vpc : "deployment6-vpc-east"
    az : "us-east-1a"
=======
    Name : "applicationServer01-east"
    vpc : "deployment6-vpc-east"
    az : "${var.regionvpc1}a"
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  }
}


 #create second instance:VPC in US-east-1
<<<<<<< HEAD
resource "aws_instance" "D6appServer02-east" {
=======
resource "aws_instance" "applicationServer02-east" {
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  provider = aws.us-east-1
  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG.id]
  subnet_id = aws_subnet.dep6publicSubnetB.id 
  associate_public_ip_address = true
  key_name = var.key_name 
   
  user_data = "${file("software.sh")}"

  tags = {
<<<<<<< HEAD
    Name : "D6appServer01-east"
    vpc : "deployment6-vpc-east"
    az : "us-east-1b"
=======
    Name : "applicationServer02-east"
    vpc : "deployment6-vpc-east"
    az : "${var.regionvpc1}b"
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  }
}  


<<<<<<< HEAD
output "applicationServer01-east_ip" {
  value = aws_instance.D6appServer01-east.public_ip
}

output "applicationServer02-east_ip" {
  value = aws_instance.D6appServer02-east.public_ip
=======
# create security group: VPC in US-east-1

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
     from_port = 80
    to_port = 80
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

output "applicationServer01-east_ip" {
  value = aws_instance.applicationServer01-east.public_ip
}

output "applicationServer02-east_ip" {
  value = aws_instance.applicationServer02-east.public_ip
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
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
  access_key = var.access_key
  secret_key = var.secret_key
<<<<<<< HEAD
  region = "us-west-2"
=======
  region = var.regionvpc2
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
}

#
#
resource "aws_vpc" "deployment6-vpc-west" {
  provider = aws.us-west-2
<<<<<<< HEAD
  cidr_block       = "10.0.0.0/16"
=======
  cidr_block       = var.vpcwest_cidr
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
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
<<<<<<< HEAD
  availability_zone = "us-west-2a"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true

=======
  availability_zone = "${var.regionvpc2}a"
  cidr_block = var.dep6publicSubnetC_cidr
  map_public_ip_on_launch = true

  //subnet config
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2

  tags = {
    Name = "dep6publicSubnetC"
    vpc : "deployment6-vpc-west"
<<<<<<< HEAD
    az : "us-west-2a"
=======
    az : "${var.regionvpc2}a"
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  }
}

output "pub_subnetc_id" {
  value = aws_subnet.dep6publicSubnetC.id
}


#create subnet D: VPC in US-west-2
resource "aws_subnet" "dep6publicSubnetD" {
  provider = aws.us-west-2
  vpc_id     = aws_vpc.deployment6-vpc-west.id
<<<<<<< HEAD
  availability_zone = "us-west-2b"
  cidr_block = "10.0.1.0/24"
=======
  availability_zone = "${var.regionvpc2}b"
  cidr_block = var.dep6publicSubnetD_cidr
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "dep6publicSubnetD"
    vpc : "deployment6-vpc-west"
<<<<<<< HEAD
    az : "us-west-2b"
=======
    az : "${var.regionvpc2}b"
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
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
<<<<<<< HEAD
resource "aws_instance" "D6appServer01-west" {
  provider = aws.us-west-2
  ami = "ami-0efcece6bed30fd98"
=======
resource "aws_instance" "applicationServer01-west" {
  provider = aws.us-west-2
  ami = "ami-0cd5f46e93e42a496"
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG-west.id]
  subnet_id = aws_subnet.dep6publicSubnetC.id
  associate_public_ip_address = true
  key_name = "us-west-2"

  user_data = "${file("software.sh")}"

  tags = {
<<<<<<< HEAD
    Name : "D6appServer01-west"
    vpc : "deployment6-vpc-west"
    az : "us-west-2a"
=======
    Name : "applicationServer01-west"
    vpc : "deployment6-vpc-west"
    az : "${var.regionvpc2}a"
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  }
}


 #create second instance:VPC in US-west-2
<<<<<<< HEAD
resource "aws_instance" "D6appServer02-west" {
=======
resource "aws_instance" "applicationServer02-west" {
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  provider = aws.us-west-2
  ami = "ami-0cd5f46e93e42a496"
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG-west.id]
  subnet_id = aws_subnet.dep6publicSubnetD.id 
  associate_public_ip_address = true
  key_name = "us-west-2" 
   
  user_data = "${file("software.sh")}"

  tags = {
<<<<<<< HEAD
    Name : "D6appServer02-west"
    vpc : "deployment6-vpc-west"
    az : "us-west-2b"
=======
    Name : "applicationServer02-west"
    vpc : "deployment6-vpc-west"
    az : "${var.regionvpc2}b"
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  }
}  


<<<<<<< HEAD
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

=======
# create security group: VPC in US-west-2
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2

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

<<<<<<< HEAD

=======
>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

<<<<<<< HEAD
=======
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
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

<<<<<<< HEAD


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
=======
output "applicationServer01-west_ip" {
  value = aws_instance.applicationServer01-west.public_ip
}

output "applicationServer02-west_ip" {
  value = aws_instance.applicationServer02-west.public_ip
}

>>>>>>> 1e04ae357ac50996fa185d9f4a18295fd1b067b2
