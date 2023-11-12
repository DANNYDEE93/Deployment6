provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = "us-east-1"
}
#
#
#create first instance:default-vpc with jenkins and deadsnakes
resource "aws_instance" "Dep6JenkinsManager" {
  ami = var.ami
  instance_type = var.instance_type
  availability_zone = "us-east-1a"
  vpc_security_group_ids = ["sg-08d4347ac732ab2a4"]
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("jenkins-deadsnakes.sh")}"

  tags = {
    Name : "Dep6JenkinsManager"
  }
}
#
#
#create second instance:default-vpc with terraform and java environment
resource "aws_instance" "D6TerraformAgent" {
  provider = aws
  ami = var.ami
  instance_type = var.instance_type
  availability_zone = "us-east-1a"
  vpc_security_group_ids = ["sg-08d4347ac732ab2a4"]
  associate_public_ip_address = true
  key_name = var.key_name

  user_data = "${file("terraform-java.sh")}"

  tags = {
    Name : "D6TerraformAgent"
  }
}
#
#output values
output "dep6server1_ip" {
  value = aws_instance.Dep6JenkinsManager.public_ip
}

output "dep6erver2_ip" {
  value = aws_instance.D6TerraformAgent.public_ip
}

