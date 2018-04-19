resource "aws_vpc_dhcp_options" "mydhcp" {
    domain_name = "${var.DnsZoneName}"
    domain_name_servers = ["AmazonProvidedDNS"]
    tags {
      Name = "demo Dhcp"
    }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
    vpc_id = "${aws_vpc.demo.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.mydhcp.id}"
}

resource "aws_route53_zone" "main" {
  name = "${var.DnsZoneName}"
  vpc_id = "${aws_vpc.demo.id}"
  comment = "Created for Demo"
}

resource "aws_route53_record" "database" {
   zone_id = "${aws_route53_zone.main.zone_id}"
   name = "mydatabase.${var.DnsZoneName}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.database.private_ip}"]
}
resource "aws_vpc" "demo" {
    cidr_block = "${var.vpc-fullcidr}"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags {
      Name = "demo vpc"
    }
}
# Declare the data source
data "aws_availability_zones" "available" {}

/* EXTERNAL NETWORG , IG, ROUTE TABLE */
resource "aws_internet_gateway" "gw" {
   vpc_id = "${aws_vpc.demo.id}"
    tags {
        Name = "internet gw demo"
    }
}
resource "aws_network_acl" "all" {
   vpc_id = "${aws_vpc.demo.id}"
    egress {
        protocol = "-1"
        rule_no = 2
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    ingress {
        protocol = "-1"
        rule_no = 1
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
    tags {
        Name = "open acl"
    }
}
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.demo.id}"
  tags {
      Name = "Public"
  }
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }
}
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.demo.id}"
  tags {
      Name = "Private"
  }
  route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.PublicAZA.id}"
  }
}
resource "aws_eip" "forNat" {
    vpc      = true
}
resource "aws_nat_gateway" "PublicAZA" {
    allocation_id = "${aws_eip.forNat.id}"
    subnet_id = "${aws_subnet.PublicAZA.id}"
	subnet_id = "${aws_subnet.PublicAZA2.id}"
    depends_on = ["aws_internet_gateway.gw"]
}
###################Public Subnet 1#########################
resource "aws_subnet" "PublicAZA" {
  vpc_id = "${aws_vpc.demo.id}"
  cidr_block = "${var.Subnet-Public-AzA-CIDR}"
  tags {
        Name = "PublicAZA"
  }
 availability_zone = "${data.aws_availability_zones.available.names[0]}"
}
resource "aws_route_table_association" "PublicAZA" {
    subnet_id = "${aws_subnet.PublicAZA.id}"
    route_table_id = "${aws_route_table.public.id}"
}
############################################
############Public Subnet 2#################
resource "aws_subnet" "PublicAZA2" {
  vpc_id = "${aws_vpc.demo.id}"
  cidr_block = "${var.Subnet-Public-AzA2-CIDR}"
  tags {
        Name = "PublicAZA2"
  }
 availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_route_table_association" "PublicAZA2" {
    subnet_id = "${aws_subnet.PublicAZA2.id}"
    route_table_id = "${aws_route_table.public.id}"
}
##################################################
###############Private Subnet 1#######################
resource "aws_subnet" "PrivateAZA" {
  vpc_id = "${aws_vpc.demo.id}"
  cidr_block = "${var.Subnet-Private-AzA-CIDR}"
  tags {
        Name = "PublicAZB"
  }
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
}
resource "aws_route_table_association" "PrivateAZA" {
    subnet_id = "${aws_subnet.PrivateAZA.id}"
    route_table_id = "${aws_route_table.private.id}"
}
##################################################
#################Private Subnet 2##################
resource "aws_subnet" "PrivateAZA2" {
  vpc_id = "${aws_vpc.demo.id}"
  cidr_block = "${var.Subnet-Private-AzA2-CIDR}"
  tags {
        Name = "PublicAZB2"
  }
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_route_table_association" "PrivateAZA2" {
    subnet_id = "${aws_subnet.PrivateAZA2.id}"
    route_table_id = "${aws_route_table.private.id}"
}
##############################################
####################Load Balancer#############
resource "aws_elb" "web" {
  name = "demo-elb"
  subnets = ["${aws_subnet.PublicAZA.id}"]
  security_groups = ["${aws_security_group.webserver.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = ["${aws_instance.webserver.id}","${aws_instance.webserver_Backup.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}

########################Db_Subnet_group#####################
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds-subnet-grp"
  subnet_ids = [
    "${aws_subnet.PrivateAZA.id}",
    "${aws_subnet.PrivateAZA2.id}",
  ]
  tags = {
    Name              = "staging.demo.abc"
    Environment       = "staging"
  }
}
resource "aws_db_parameter_group" "rds_db" {
  name   = "database"
  family = "mysql5.6"
} 
