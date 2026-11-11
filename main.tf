resource "aws_instance" "terraform_demo" {
  ami                    = data.aws_ami.joindevops.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_docker.id]

  # User data with templatefile
  user_data = templatefile("${path.module}/docker.sh.tftpl", {
    partition_number = 4
    extend_size      = 30
  })

  root_block_device {
    volume_size = 50    # Size of the volume in GiB
    volume_type = "gp3" # General Purpose SSD
    tags = {
      Name        = "docker"
      Project     = "roboshop"
      Environment = "dev"
    }
  }

  tags = {
    Name        = "docker"
    Project     = "roboshop"
    Environment = "dev"
  }
}

# Creates in default VPC
resource "aws_security_group" "allow_docker" {
  name        = "allow_terraform"
  description = "Allow SSH, HTTP inbound traffic and all outbound traffic"

  
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"]
  }

  
  ingress {
    description = "HTTP from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      =  ["0.0.0.0/0"]
  }

 
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_docker"
  }
}