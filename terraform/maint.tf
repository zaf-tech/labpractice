provider "aws" {
  region = "us-east-2"  # Choose your desired region
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_1"
  description = "Allow SSH access"

  # Ingress rule to allow SSH (port 22) from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs for SSH, can be restricted as needed
  }

  # Egress rule to allow outbound traffic (default allows all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-0604f27d956d83a4d"  # Replace with a valid Amazon Linux AMI ID for your region
  instance_type = "t2.micro"                # Instance type (t2.micro)
  key_name      = "khuddam"           # Replace with your SSH key name for EC2 login
  security_groups = [aws_security_group.allow_ssh.name]
  user_data = base64encode(file("${path.module}/script/ansible.sh"))
  tags = {
    Name = "MyLinuxInstance"
  }
}

output "instance_public_ip" {
  value = aws_instance.my_ec2_instance.public_ip
}
