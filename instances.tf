resource "aws_instance" "webserver" {
  ami = "${lookup(var.AmiLinux, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.PublicAZA.id}"
  vpc_security_group_ids = ["${aws_security_group.webserver.id}"]
  key_name = "Private-key"
  tags {
        Name = "webserver"
  }
 connection {
            user = "ubuntu"
            private_key = "${file("path to private_key")}"
        }
  provisioner "file" {
        source = "path to private_key"
        destination = "destination path for private_key"
        
   }
   user_data = "${file("apache.sh")}"
}

resource "aws_instance" "webserver_Backup" {
  ami = "${lookup(var.AmiLinux, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.PublicAZA.id}"
  vpc_security_group_ids = ["${aws_security_group.webserver.id}"]
  key_name = "ansible_docker"
  tags {
        Name = "webserver_Backup"
  }
  user_data = "${file("Server.sh")}"
}
resource "aws_instance" "database" {
  ami = "${lookup(var.AmiLinux, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "false"
  subnet_id = "${aws_subnet.PrivateAZA.id}"
  vpc_security_group_ids = ["${aws_security_group.Database.id}"]
  key_name = "ansible_docker"
  tags {
        Name = "database"
  }
 user_data = "${file("mysql.sh")}"
}
resource "aws_db_instance" "mydb1" {  
  allocated_storage        = 20 # gigabytes
  backup_retention_period  = 7   # in days
  db_subnet_group_name     = "${aws_db_subnet_group.rds_subnet.name}"
  parameter_group_name     = "${aws_db_parameter_group.rds_db.name}"
  engine                   = "mysql"
  engine_version           = "5.6.39"
  identifier               = "mydb1"
  instance_class           = "db.t2.large"
  multi_az                 = false
  name                     = "mysqldatabase"
  port                     = 3306
  publicly_accessible      = false
  storage_encrypted        = false # you should always do this
  storage_type             = "gp2"
  username                 = "user id"
  password	               = "password"
  vpc_security_group_ids   = ["${aws_security_group.rds.id}"]
 }
