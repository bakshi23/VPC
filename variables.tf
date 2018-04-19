provider "aws" {
			access_key = "your aws access_key"
			secret_key = "you aws secret_key"
			region     = "${var.region}"
}
variable "region" {
  default = "ap-southeast-1"
}
variable "AmiLinux" {
  type = "map"
  default = {
    ap-southeast-1 = "ami-52d4802e"
    }
  
 }
variable "vpc-fullcidr" {
    default = "172.28.0.0/16"
  description = "the vpc cdir"
}
variable "Subnet-Public-AzA-CIDR" {
  default = "172.28.0.0/24"
  description = "the cidr of the subnet"
}
variable "Subnet-Public-AzA2-CIDR" {
  default = "172.28.1.0/24"
  description = "the cidr of the subnet"
}
variable "Subnet-Private-AzA-CIDR" {
  default = "172.28.3.0/24"
  description = "the cidr of the subnet"
}
variable "Subnet-Private-AzA2-CIDR" {
  default = "172.28.4.0/24"
  description = "the cidr of the subnet"
}
variable "key_name" {
  default = "your private-key"
  description = "the ssh key to use in the EC2 machines"
}
variable "DnsZoneName" {
  default = "demo.abc"
  description = "the internal dns name"
}
variable "rds_public_subnet_group" {  
  default = "vpc-fullcidr"
  description = "group name,RDS"
}