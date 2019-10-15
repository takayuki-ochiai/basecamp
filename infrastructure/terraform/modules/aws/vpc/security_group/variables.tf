variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "port" {
  type = number
}

variable "protocol" {
  type    = string
  default = "tcp"
}

variable "cidr_blocks" {
  type = "list"
}
