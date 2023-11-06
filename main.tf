separate instances in main.tf

make the key
update the tfvars
then terraform destroy 

# configure aws provider
provider "aws" {
  alias = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.regionvpc1
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

