locals {
  name_prefix = "zirong" # provide your name prefix
tags = {
    Purpose = "Zirong - Assignment 2.7"
  }
}


# EC2 Instances
resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazon2023.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.public.ids[0] # Use the first subnet in the list
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2-ebs-sg.id]
 
  tags = {
    Name = "${local.name_prefix}-ec2-ebs"
  }
}

# Security Group
resource "aws_security_group" "ec2-ebs-sg" {
  name        ="${local.name_prefix}-ec2-ebs-sg"
  description = "Allow public traffic to alb"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description      = "SSH from outside world"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create an EBS Volume
resource "aws_ebs_volume" "ebs-volume" {
  availability_zone = aws_instance.public.availability_zone
  size              = 1 # Volume size in GiB
  tags = {
    Name = "zirong-ec2-ebs-volume"
  }
}

# Attach the EBS Volume to the EC2 Instance
resource "aws_volume_attachment" "volumeattachment" {
  device_name = "/dev/sdb"  # Replace with your desired device name
  volume_id   = aws_ebs_volume.ebs-volume.id
  instance_id = aws_instance.public.id
}





