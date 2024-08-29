variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "public_subnets" {
  description = "Public subnets of VPC"
  type = list(string)
  default = ["10.21.0.0/24", "10.21.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnets of VPC"
  type = list(string)
  default = ["10.21.1.0/16", "10.21.3.0/16"]
}
