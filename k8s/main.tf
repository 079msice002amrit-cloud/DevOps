provider "aws" {
  region = "us-east-1"
}

data "aws_security_group" "sg" {
  filter {
    name   = "group-name"
    values = ["launch-wizard-1"]
  }
}

resource "aws_instance" "servers" {
  for_each = toset(["server1", "ansible"])

  ami                    = "ami-0360c520857e3138f"
  instance_type          = "t2.medium"
  key_name               = "test"
  vpc_security_group_ids = [data.aws_security_group.sg.id]

  tags = {
    Name = each.key
  }
}