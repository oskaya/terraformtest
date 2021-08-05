provider "aws" {
  region = "eu-west-1"
}


resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "my-vpc"
    "env" = var.environment
  }
}

resource "aws_subnet" "my-vpc-public-subnet-1" {
  vpc_id = aws_vpc.my-vpc.id

  cidr_block = "10.0.1.0/24"

  map_public_ip_on_launch = true

  tags = {
    "Name" = "my-public-subnet-1"
    "env"  = var.environment
  }
}


resource "aws_internet_gateway" "my-vpc-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "myvpc-igw"
  }
}


resource "aws_route_table" "myvpc-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-vpc-igw.id
  }


  tags = {
    Name = "myvpc-rt"
  }
}


resource "aws_route_table_association" "subnet-rt-assoc" {
    subnet_id = aws_subnet.my-vpc-public-subnet-1.id
    route_table_id = aws_route_table.myvpc-rt.id
  
}
data "aws_ami" "latest-amazon-linux-2" {
  most_recent = true
  owners =["amazon"]

  filter {
    name = "name"
    values= ["amzn2-ami-*-x86_64-gp2"]
  }

  filter {
    
    name   = "virtualization-type"
    values = ["hvm"]
  
  }

    
}

resource "aws_instance" "my-server" {
  
  ami = data.aws_ami.latest-amazon-linux-2.id

  instance_type = var.instance_type

  key_name = aws_key_pair.myserver-key-pair.key_name

  

  subnet_id = aws_subnet.my-vpc-public-subnet-1.id

  security_groups = [aws_security_group.allow_ssh.id]

connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("/home/umut/.ssh/amazon-key.pem")
    host = self.public_ip
  }
provisioner "remote-exec" {
  inline = [
    "sudo yum update -y","sudo yum install docker -y","sudo systemctl start docker","sudo docker run -d -p 80:80 nginx "
  ]
}


  tags = {
    "Name" = "${var.environment}-my-server"
  }

}

resource "aws_key_pair" "myserver-key-pair" {

    key_name = "amazon-key.pem"
    public_key = file("/home/umut/.ssh/amazon-key.pem.pub")
  
}

output "server-public-ip" {
    value = aws_instance.my-server.public_ip  
}



resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

   ingress {
    
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.myip]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  
  }

  tags = {
    Name = "allow_tls"
  }
}