# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------


variable "vpc_name" {
  description = "The name of the VPC"

}

variable "vpc_cidr" {
  description = "The CIDR list of the VPC"
  default = null

}

variable "subnet_vpc_id" {
  description = "ID of the VPC"
  default = null
}


variable "networks" {
  type = list(object({
    name    = string
    az = string
    cidr = any
    ntype = string
  }))
}

variable "route_tables" {
  type = list(object({
    name    = string
    rtype   = string
  }))
}

variable "igw_name" {
  type = string
  default = "Test"
}

variable "on_prem_cidr" {

  type = string
  default = null
}