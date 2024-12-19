locals {
  name_prefix = "zirong" # provide your name prefix
}
# EC2 Instances
resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazon2023.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.public.ids[0] # Use the first subnet in the list
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
 
  tags = {
    Name = "${local.name_prefix}-ec2-ebs"
  }
}

resource "aws_security_group" "sg" {
  name        = "${local.name_prefix}-ec2-ebs-sg"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id  = data.aws_vpc.selected.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
resource "aws_volume_attachment" "example" {
  device_name = "/dev/sdb"  # Replace with your desired device name
  volume_id   = aws_ebs_volume.ebs-volume.id
  instance_id = aws_instance.public.id
}
