variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}
variable "common_tags" {
  type = map(string)
  default = {
  
  }
}
variable "vpc_tag" {
  default = {}
}
variable "igw_tag" {
  default = {}
}

variable "enable_dns_hostnames" {
  type = bool
  default =true
}
variable "project" {
  type = string
}
variable "environment" {
  type = string
}
variable "public_cidr" {
  type = list(string)
  validation {
    condition = length(var.public_cidr)==2
    error_message = "please give 2 values only"
  }
}
variable "public_sub_tag" {
  default = {}
}
variable "private_cidr" {
  type = list
  validation {
    condition = length(var.private_cidr)==2
    error_message = "please give 2 values only"
  }
}
variable "private_sub_tag" {
  default = {}
}
variable "database_cidr" {
  type = list
  validation {
    condition = length(var.database_cidr)==2
    error_message = "please give 2 values only"
  }
}
variable "database_sub_tag" {
  default = {}
}

variable "ngw_tag" {
  default = {}
}

variable "public_rtbale_tag" {
  default = {}
}
variable "private_rtbale_tag" {
  default = {}
}
variable "database_rtbale_tag" {
  default = {}
}
variable "is_peering_required" {
  type = bool
  default = false
}
variable "acceptor_vpc_id" {
  type = string
  default = ""
}
variable "peering_tag" {
  default = {}
}