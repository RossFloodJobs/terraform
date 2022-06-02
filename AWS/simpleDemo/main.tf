# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}



resource "aws_vpc" "prod_VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "prodVPC"
  }
}


resource "aws_internet_gateway" "prod_gateway" {
  vpc_id = aws_vpc.prod_VPC.id

  tags = {
    Name = "prodGateway"
  }
}


resource "aws_route_table" "prod_routeTable" {
  vpc_id = aws_vpc.prod_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.prod_gateway.id
  }

  tags = {
    Name = "prodRouteTable"
  }
}

resource "aws_subnet" "prod_subnet" {
  vpc_id     = aws_vpc.prod_VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "prodSubnet"
  }
}


resource "aws_route_table_association" "prod_routeTableAssociation" {
  subnet_id      = aws_subnet.prod_subnet.id
  route_table_id = aws_route_table.prod_routeTable.id
}

resource "aws_security_group" "allowWweb" {
  name        = "allowWweb"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.prod_VPC.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allowWweb"
  }
}

resource "aws_network_interface" "webNIC" {
  subnet_id       = aws_subnet.prod_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allowWweb.id]

}

resource "aws_eip" "publicIP" {
  vpc                       = true
  network_interface         = aws_network_interface.webNIC.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [
    aws_internet_gateway.prod_gateway
  ]
}

resource "aws_instance" "ubuntu-server" {
    ami = "ami-085925f297f89fce1"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"

    key_name = "terraform_key"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.webNIC.id
    }

    user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd.x86_64
                systemctl start httpd.service
                systemctl enable httpd.service
                echo "Hello from Terraform deployed website!" > /var/www/html/index.html
                EOF

    tags = {
      Name = "demo_Ubuntu"
    }
}