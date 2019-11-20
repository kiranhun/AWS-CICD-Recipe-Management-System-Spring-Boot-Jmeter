resource "aws_security_group" "loadBalancerSecurityGroup" {
  name = "loadBalancerSecurityGroup"
  vpc_id = module.networking.vpc_id
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webapp"{
  name = "application"
  vpc_id = module.networking.vpc_id
  tags = {
    Name = "application security group"
  }

  //  ingress {
  //    to_port = 22
  //    from_port = 22
  //    protocol = "tcp"
  //    cidr_blocks = ["0.0.0.0/0"]
  //  }

  //  ingress {
  //    to_port = 80
  //    from_port = 80
  //    protocol = "tcp"
  //    cidr_blocks = ["0.0.0.0/0"]
  //  }

  ingress {
    to_port = 443
    from_port = 443
    protocol = "tcp"
    //    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.loadBalancerSecurityGroup.id]
  }

  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_security_group" "database"{
  name = "database"
  vpc_id = module.networking.vpc_id
  tags = {
    Name = "database security group"
  }
  #Mysql
  ingress {
    to_port = 3306
    from_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.webapp.id]
  }
}
