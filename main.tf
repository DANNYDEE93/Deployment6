# configure aws provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.regionvpc1
}

#first vpc:VPC in US-east-1
resource "aws_vpc" "deployment6-vpc-east" {
  cidr_block       = var.vpceast_cidr
  instance_tenancy = "default"

  tags = {
    Name = "deployment6-vpc-east"
  }
}

output "vpc_id" {
  value = aws_vpc.deployment6-vpc-east.id
}


#create subnet A: VPC in US-east-1
resource "aws_subnet" "dep6publicSubnetA" {
  vpc_id     = aws_vpc.deployment6-vpc-east.id
  availability_zone = "${var.regionvpc1}a"
  cidr_block = var.dep6publicSubnetA_cidr
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "dep6publicSubnetA"
    vpc : "deployment6-vpc-east"
    az : "${var.regionvpc1}a"
  }
}

output "pub_subneta_id" {
  value = aws_subnet.dep6publicSubnetA.id
}


#create subnet B: VPC in US-east-1
resource "aws_subnet" "dep6publicSubnetB" {
  vpc_id     = aws_vpc.deployment6-vpc-east.id
  availability_zone = "${var.regionvpc1}b"
  cidr_block = var.dep6publicSubnetB_cidr
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "dep6publicSubnetB"
    vpc : "deployment6-vpc-east"
    az : "${var.regionvpc1}b"
  }
}

output "pub_subnetb_id" {
  value = aws_subnet.dep6publicSubnetB.id
}

#create route table:VPC in US-east-1
resource "aws_route_table" "deployment6-rt" {
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
  subnet_id      = aws_subnet.dep6publicSubnetA.id
  route_table_id = aws_route_table.deployment6-rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.dep6publicSubnetB.id
  route_table_id = aws_route_table.deployment6-rt.id
}

#create internet gateway: VPC in US-east-1
resource "aws_internet_gateway" "deployment6_igw" {
  vpc_id = aws_vpc.deployment6-vpc-east.id

  // igw config

  tags = {
    Name = "deployment6_igw"

  }

}



resource "aws_lb" "ALB-east" {
  name               = "ALB-east"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SSH-HttpAcessSG.id]
  subnets            = [aws_subnet.dep6publicSubnetA.id, aws_subnet.dep6publicSubnetB.id]

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.dep6ALB-east-logs.id
    prefix  = "ALB-east"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}


 #create first instance:VPC in US-east-1
resource "aws_instance" "applicationServer01-east" {

  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG.id]
  subnet_id = aws_subnet.dep6publicSubnetA.id
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("software.sh")}"

  tags = {
    Name : "applicationServer01-east"
    vpc : "deployment6-vpc-east"
    az : "${var.regionvpc1}a"
  }
}


 #create second instance:VPC in US-east-1
resource "aws_instance" "applicationServer02-east" {

  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG.id]
  subnet_id = aws_subnet.dep6publicSubnetB.id 
  associate_public_ip_address = true
  key_name = var.key_name 
   
  user_data = "${file("software.sh")}"

  tags = {
    Name : "applicationServer02-east"
    vpc : "deployment6-vpc-east"
    az : "${var.regionvpc1}b"
  }
}  


# create security group: VPC in US-east-1

resource "aws_security_group" "SSH-HttpAcessSG" {
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

output "applicationServer01-east_ip" {
  value = aws_instance.applicationServer01-east.public_ip
}

output "applicationServer02-east_ip" {
  value = aws_instance.applicationServer02-east.public_ip
}

#
#
#
#
#configurations for second vpc
#second vpc:VPC in US-west-2
#
#
#
resource "aws_vpc" "deployment6-vpc-west" {
  cidr_block       = var.vpcwest_cidr
  instance_tenancy = "default"

  tags = {
    Name = "deployment6-vpc-west"
  }
}

output "vpc_id" {
  value = aws_vpc.deployment6-vpc-west.id
}


#create subnet C: VPC in US-west-2
resource "aws_subnet" "dep6publicSubnetC" {
  vpc_id     = aws_vpc.deployment6-vpc-west.id
  availability_zone = "${var.regionvpc2}a"
  cidr_block = var.dep6publicSubnetC_cidr
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "dep6publicSubnetC"
    vpc : "deployment6-vpc-west"
    az : "${var.regionvpc2}a"
  }
}

output "pub_subneta_id" {
  value = aws_subnet.dep6publicSubnetC.id
}


#create subnet D: VPC in US-west-2
resource "aws_subnet" "dep6publicSubnetD" {
  vpc_id     = aws_vpc.deployment6-vpc-west.id
  availability_zone = "${var.regionvpc2}b"
  cidr_block = var.dep6publicSubnetD_cidr
  map_public_ip_on_launch = true

  //subnet config

  tags = {
    Name = "dep6publicSubnetD"
    vpc : "deployment6-vpc-west"
    az : "${var.regionvpc2}b"
  }
}

output "pub_subnetb_id" {
  value = aws_subnet.dep6publicSubnetD.id
}

#create route table:VPC in US-west-2
resource "aws_route_table" "deployment6-rt-west" {
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
  subnet_id      = aws_subnet.dep6publicSubnetC.id
  route_table_id = aws_route_table.deployment6-rt-west.id
}

resource "aws_route_table_association" "public_d" {
  subnet_id      = aws_subnet.dep6publicSubnetD.id
  route_table_id = aws_route_table.deployment6-rt-west.id
}

#create internet gateway: VPC in US-west-2
resource "aws_internet_gateway" "deployment6_igw-west" {
  vpc_id = aws_vpc.deployment6-vpc-west.id

  // igw config

  tags = {
    Name = "deployment6_igw-west"

  }

}

#create load balancer:VPC in US-west-2

resource "aws_lb" "ALB-west" {
  name               = "ALB-west"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SSH-HttpAcessSG.id]
  subnets            = [aws_subnet.dep6publicSubnetA.id, aws_subnet.dep6publicSubnetB.id]

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.dep6ALB-west-logs.id
    prefix  = "ALB-west"
    enabled = true
  }

  tags = {
    Environment = "production2"
  }
}


 #create first instance:VPC in US-west-2
resource "aws_instance" "applicationServer01-west" {

  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG.id]
  subnet_id = aws_subnet.dep6publicSubnetC.id
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("software.sh")}"

  tags = {
    Name : "applicationServer01-west"
    vpc : "deployment6-vpc-west"
    az : "${var.regionvpc2}a"
  }
}


 #create second instance:VPC in US-west-2
resource "aws_instance" "applicationServer02-west" {

  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.SSH-HttpAcessSG.id]
  subnet_id = aws_subnet.dep6publicSubnetD.id 
  associate_public_ip_address = true
  key_name = var.key_name 
   
  user_data = "${file("software.sh")}"

  tags = {
    Name : "applicationServer02-west"
    vpc : "deployment6-vpc-west"
    az : "${var.regionvpc2}b"
  }
}  


# create security group: VPC in US-west-2

resource "aws_security_group" "SSH-HttpAcessSG-west" {
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

output "applicationServer01-west_ip" {
  value = aws_instance.applicationServer01-west.public_ip
}

output "applicationServer02-west_ip" {
  value = aws_instance.applicationServer02-west.public_ip
}

