variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "public_key_path" {
  type    = string
  default = "./key_pair.pub"
}