output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_1_id" {
  value = module.public_subnet_1.subnet_id
}

output "public_subnet_2_id" {
  value = module.private_subnet_1.subnet_id
}
