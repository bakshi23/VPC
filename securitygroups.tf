resource "aws_security_group" "webserver" {
  name = "webserver"
  tags {
        Name = "webserver"
  }
  description = "ONLY HTTP CONNECTION INBOUD"
  vpc_id = "${aws_vpc.demo.id}"

  ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "Database" {
  name = "Database"
  tags {
        Name = "Database"
  }
  description = "ONLY tcp CONNECTION INBOUND"
  vpc_id = "${aws_vpc.demo.id}"
  ingress {
      from_port = 3306
      to_port = 3306
      protocol = "TCP"
      security_groups = ["${aws_security_group.webserver.id}"]
  }
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "TCP"
        cidr_blocks = ["172.28.0.0/16"]
  }
  ingress {
      from_port   = "22"
      to_port     = "22"
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "rds" {  
  name = "rds"

  description = "Mysql Server  created for demo"
  vpc_id = "${aws_vpc.demo.id}"

  # Only mysql port allowed
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}