#  * VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#  * Route Table association


resource "aws_vpc" "unzer" {
  cidr_block = "10.0.0.0/16"

  tags = map(
    "Name", "terraform-eks-unzer-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "unzer" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.unzer.id
  map_public_ip_on_launch = true

  tags = map(
    "Name", "terraform-eks-unzer-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "unzer" {
  vpc_id = aws_vpc.unzer.id

  tags = {
    Name = "terraform-eks-unzer"
  }
}

resource "aws_route_table" "unzer" {
  vpc_id = aws_vpc.unzer.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.unzer.id
  }
}

resource "aws_route_table_association" "unzer" {
  count = 2

  subnet_id      = aws_subnet.unzer.*.id[count.index]
  route_table_id = aws_route_table.unzer.id
}
