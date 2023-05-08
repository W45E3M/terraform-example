resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(
    { Name = var.name },
    local.tags
  )
}


#virtual private cloud is defined below:
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    { Name = var.name },
    local.tags
  )
}

#The public and private subnets,route tables and route table associations are defined below:
resource "aws_subnet" "public" {
  count = var.public_subnet_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.newbits, count.index + var.newbits / 2)
  availability_zone = data.aws_availability_zones.current.names[count.index]

  tags = merge(
    { Name = "${var.name}-public-${count.index}" },
    local.tags
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = local.tags

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  count = var.private_subnet_count

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.newbits, count.index)
  availability_zone = data.aws_availability_zones.current.names[count.index]

  tags = merge(
    { Name = "${var.name}-private-${count.index}" },
    local.tags
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = local.tags

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Elastic ip address is created below
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = merge(
    { Name = var.name },
    local.tags
  )
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    { Name = var.name },
    local.tags
  )
}

