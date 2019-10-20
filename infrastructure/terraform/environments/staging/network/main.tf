resource "aws_vpc" "vpc" {
  cidr_block = "10.2.0.0/16"

  // AWS の DNS サーバによる名前解決を有効にする
  enable_dns_support = true

  // trueにするとこのVPC内部のリソースにパブリックDNSホスト名が自動で割り当てられる
  enable_dns_hostnames = true

  tags = {
    Name      = "${var.project_name}-${var.env}-vpc"
    ManagedBy = "Terraform"
  }
}

module "public_subnet_1" {
  source                  = "../../../modules/aws/vpc/subnet"
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = "ap-northeast-1a"
  name                    = "${var.project_name}-${var.env}-public-subnet-1"
  map_public_ip_on_launch = true
}

module "public_subnet_2" {
  source                  = "../../../modules/aws/vpc/subnet"
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.2.2.0/24"
  availability_zone       = "ap-northeast-1c"
  name                    = "${var.project_name}-${var.env}-public-subnet-2"
  map_public_ip_on_launch = true
}

module "private_subnet_1" {
  source                  = "../../../modules/aws/vpc/subnet"
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.2.3.0/24"
  availability_zone       = "ap-northeast-1a"
  name                    = "${var.project_name}-${var.env}-private-subnet-1"
  map_public_ip_on_launch = false
}

module "private_subnet_2" {
  source                  = "../../../modules/aws/vpc/subnet"
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.2.4.0/24"
  availability_zone       = "ap-northeast-1c"
  name                    = "${var.project_name}-${var.env}-private-subnet-2"
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "${var.project_name}-${var.env}-igw"
    ManagedBy = "Terraform"
  }
}

// publicルートテーブルとサブネットの関連付け
resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name      = "${var.project_name}-${var.env}-public-table"
    ManagedBy = "Terraform"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_table.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_1" {
  route_table_id = aws_route_table.public_table.id
  subnet_id      = module.public_subnet_1.subnet_id
}

resource "aws_route_table_association" "public_2" {
  route_table_id = aws_route_table.public_table.id
  subnet_id      = module.public_subnet_2.subnet_id
}



// privateルートテーブルとサブネットの関連付け
// NATゲートウェイ
// NATゲートウェイの設定
// NATゲートウェイにはElastic IPが必要なためEIPを先に作る
// NATゲートウェイが所属するアベイラビリティーゾーンで障害が発生すると片方のアベイラビリティーゾーンでも障害が起きるので、
// NATゲートウェイをアベイラビリティーゾーンごとに作る
resource "aws_eip" "nat_gateway_1" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name      = "${var.project_name}-${var.env}-nat-gateway-1"
    ManagedBy = "Terraform"
  }
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_1.id

  // パブリックサブネットを指定すること
  subnet_id  = module.public_subnet_1.subnet_id
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name      = "${var.project_name}-${var.env}-nat-gateway-1"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "private_table_1" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "${var.project_name}-${var.env}-private-table-1"
    ManagedBy = "Terraform"
  }
}

resource "aws_route" "private_1" {
  route_table_id = aws_route_table.private_table_1.id

  nat_gateway_id         = aws_nat_gateway.nat_gateway_1.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_1" {
  route_table_id = aws_route_table.private_table_1.id
  subnet_id      = module.private_subnet_1.subnet_id
}


resource "aws_route_table" "private_table_2" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "${var.project_name}-${var.env}-private-table-2"
    ManagedBy = "Terraform"
  }
}
//
//resource "aws_eip" "nat_gateway_2" {
//  vpc        = true
//  depends_on = [aws_internet_gateway.igw]
//
//  tags = {
//    Name      = "${var.project_name}-${var.env}-nat-gateway-2"
//    ManagedBy = "Terraform"
//  }
//}
//
//resource "aws_nat_gateway" "nat_gateway_2" {
//  allocation_id = aws_eip.nat_gateway_2.id
//
//  // パブリックサブネットを指定すること
//  subnet_id  = module.public_subnet_2.subnet_id
//  depends_on = [aws_internet_gateway.igw]
//
//  tags = {
//    Name      = "${var.project_name}-${var.env}-nat-gateway-2"
//    ManagedBy = "Terraform"
//  }
//}
//
resource "aws_route" "private_2" {
  route_table_id = aws_route_table.private_table_2.id
  // NAT Gateway自体も複数構成のMultiAZにすべきだが、予算がないので諦める…
  // 仮にAZ障害が起きた時はprivate subnetが一時的に孤立するが、許容する
  // RDSとかまでMulti-AZできない状態になるよりはマシだろうという判断
  nat_gateway_id         = aws_nat_gateway.nat_gateway_1.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_2" {
  route_table_id = aws_route_table.private_table_2.id
  subnet_id      = module.private_subnet_2.subnet_id
}
