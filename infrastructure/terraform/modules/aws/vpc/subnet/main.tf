resource "aws_subnet" "subnet" {
  cidr_block = var.cidr_block
  vpc_id     = var.vpc_id

  // このサブネットで起動したインスタンスにパブリックIPアドレスを自動的に割り当てる
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = var.availability_zone

  tags = {
    Name      = var.name
    ManagedBy = "Terraform"
  }
}
